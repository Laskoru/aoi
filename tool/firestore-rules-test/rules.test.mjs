// Règles Firestore d'AOI KOI, éprouvées dans l'émulateur.
//
// Alice possède des données ; Bob est un autre compte, « anonyme » un
// visiteur non connecté. Chaque collection est attaquée de la même façon :
// lecture, modification, suppression et usurpation par un autre, transfert
// de propriété, requêtes sans filtre. Puis les valeurs que l'appli valide.
//
// Depuis la racine du dépôt (Java 21 ou plus requis par l'émulateur) :
//   npm --prefix tool/firestore-rules-test install
//   firebase emulators:exec --only firestore --project demo-aoi "npm --prefix tool/firestore-rules-test test"

import { readFileSync } from 'node:fs';
import { after, before, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Bytes, Timestamp, addDoc, collection, deleteDoc, doc, getDoc, getDocs,
  query, serverTimestamp, setDoc, updateDoc, where, writeBatch,
} from 'firebase/firestore';

const rules = readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8');
const bytes = (kb) => Bytes.fromUint8Array(new Uint8Array(kb * 1024).fill(7));

let env;
let alice;
let bob;
let anon;

// Un document valide par collection, appartenant à Alice.
const samples = {
  kois: { userId: 'alice', name: 'Hana', variety: 'Kohaku', size: 68, sex: 'female', status: 'alive' },
  plants: { userId: 'alice', name: 'Iris des marais', zone: 'berge', quantity: 3, isFloating: false, isOxygenating: false },
  fish_groups: { userId: 'alice', species: 'Ide mélanote', count: 8 },
  measurements: { userId: 'alice', ph: 7.6, temperature: 18.5, nitrite: 0.02 },
  photos: { userId: 'alice', data: bytes(200) },
  ponds: { userId: 'alice', name: 'Mon bassin', volumeLiters: 12000 },
};
const ids = {
  kois: 'k1', plants: 'pl1', fish_groups: 'fg1', measurements: 'm1', photos: 'p1', ponds: 'default_alice',
};

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-aoi',
    firestore: { rules, host: '127.0.0.1', port: 8080 },
  });
  alice = env.authenticatedContext('alice').firestore();
  bob = env.authenticatedContext('bob').firestore();
  anon = env.unauthenticatedContext().firestore();
});

after(async () => {
  await env?.cleanup();
});

async function seed() {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const [name, data] of Object.entries(samples)) {
      await setDoc(doc(db, name, ids[name]), data);
    }
    await setDoc(doc(db, 'kois/k1/growth/g1'), { size: 60, timestamp: Timestamp.now() });
    await setDoc(doc(db, 'kois/k1/photos/kp1'), { url: 'photo:p1', takenAt: Timestamp.now() });
  });
}

for (const name of Object.keys(samples)) {
  describe(`${name} : isolement entre comptes`, () => {
    before(seed);
    const path = `${name}/${ids[name]}`;

    test('le propriétaire lit son document', () => assertSucceeds(getDoc(doc(alice, path))));
    test('un autre compte ne le lit pas', () => assertFails(getDoc(doc(bob, path))));
    test('un visiteur non connecté ne le lit pas', () => assertFails(getDoc(doc(anon, path))));
    test('un autre compte ne le modifie pas', () =>
      assertFails(updateDoc(doc(bob, path), { notes: 'piraté' })));
    test("un autre compte ne se l'approprie pas", () =>
      assertFails(setDoc(doc(bob, path), { ...samples[name], userId: 'bob' })));
    test('un autre compte ne le supprime pas', () => assertFails(deleteDoc(doc(bob, path))));
    test("personne ne crée au nom d'un autre", () =>
      assertFails(setDoc(doc(bob, `${name}/usurpe`), { ...samples[name], userId: 'alice' })));
    test("le propriétaire ne cède pas son document", () =>
      assertFails(updateDoc(doc(alice, path), { userId: 'bob' })));
    test('le propriétaire liste ses documents', () =>
      assertSucceeds(getDocs(query(collection(alice, name), where('userId', '==', 'alice')))));
    test("un autre compte ne liste pas ceux d'Alice", () =>
      assertFails(getDocs(query(collection(bob, name), where('userId', '==', 'alice')))));
    test('une requête sans filtre de propriétaire est refusée', () =>
      assertFails(getDocs(collection(alice, name))));
  });
}

describe("sous-collections d'un koï", () => {
  before(seed);

  for (const sub of ['growth', 'photos']) {
    test(`${sub} : le propriétaire du koï lit`, () =>
      assertSucceeds(getDocs(collection(alice, `kois/k1/${sub}`))));
    test(`${sub} : un autre compte ne lit pas`, () =>
      assertFails(getDocs(collection(bob, `kois/k1/${sub}`))));
    test(`${sub} : un autre compte n'ajoute rien`, () =>
      assertFails(addDoc(collection(bob, `kois/k1/${sub}`), { size: 70, url: 'photo:x' })));
  }
  test('croissance : une taille valide est acceptée', () =>
    assertSucceeds(addDoc(collection(alice, 'kois/k1/growth'), { size: 70, timestamp: serverTimestamp() })));
  test('croissance : une taille hors bornes est refusée', () =>
    assertFails(addDoc(collection(alice, 'kois/k1/growth'), { size: 250 })));
  test('croissance : un koï neuf et sa première mesure partent dans le même lot', () => {
    const batch = writeBatch(alice);
    batch.set(doc(alice, 'kois/k3'), { userId: 'alice', name: 'Mizu', size: 22 });
    batch.set(doc(alice, 'kois/k3/growth/g1'), { size: 22, timestamp: serverTimestamp() });
    return assertSucceeds(batch.commit());
  });
  test("croissance : pas de mesure sous un koï qui n'existe pas", () =>
    assertFails(setDoc(doc(alice, 'kois/absent/growth/g1'), { size: 20 })));
  test('galerie : une référence photo sans storagePath est acceptée', () =>
    assertSucceeds(addDoc(collection(alice, 'kois/k1/photos'), { url: 'photo:p1', takenAt: serverTimestamp() })));
  test("galerie : un koï absent n'a pas de galerie", () =>
    assertFails(addDoc(collection(alice, 'kois/absent/photos'), { url: 'photo:p1' })));
});

describe('valeurs validées', () => {
  before(seed);

  test('koï sans nom refusé', () =>
    assertFails(setDoc(doc(alice, 'kois/k2'), { userId: 'alice', size: 20 })));
  test('koï de plus de 200 cm refusé', () =>
    assertFails(setDoc(doc(alice, 'kois/k2'), { userId: 'alice', name: 'Géant', size: 250 })));
  test('nom de koï de plus de 80 caractères refusé', () =>
    assertFails(setDoc(doc(alice, 'kois/k2'), { userId: 'alice', name: 'x'.repeat(81), size: 20 })));
  test('pH supérieur à 14 refusé', () =>
    assertFails(setDoc(doc(alice, 'measurements/m2'), { userId: 'alice', ph: 15, temperature: 18 })));
  test('température non numérique refusée', () =>
    assertFails(setDoc(doc(alice, 'measurements/m2'), { userId: 'alice', ph: 7, temperature: 'chaud' })));
  test('zone de plante inconnue refusée', () =>
    assertFails(setDoc(doc(alice, 'plants/pl2'), { userId: 'alice', name: 'Lotus', zone: 'ciel' })));
  test('quantité négative refusée', () =>
    assertFails(setDoc(doc(alice, 'plants/pl2'), { userId: 'alice', name: 'Lotus', quantity: -1 })));
  test('effectif décimal refusé', () =>
    assertFails(setDoc(doc(alice, 'fish_groups/fg2'), { userId: 'alice', species: 'Ide', count: 2.5 })));
  test('photo de plus de 900 Ko refusée', () =>
    assertFails(setDoc(doc(alice, 'photos/p2'), { userId: 'alice', data: bytes(950) })));
  test("photo qui n'est pas binaire refusée", () =>
    assertFails(setDoc(doc(alice, 'photos/p2'), { userId: 'alice', data: 'texte' })));
  test('photo jamais modifiée, même par son propriétaire', () =>
    assertFails(updateDoc(doc(alice, 'photos/p1'), { data: bytes(10) })));
  test('le propriétaire supprime sa photo', () => assertSucceeds(deleteDoc(doc(alice, 'photos/p1'))));
});

describe('bassin par défaut', () => {
  before(seed);

  test('lire un bassin pas encore créé est permis', () =>
    assertSucceeds(getDoc(doc(bob, 'ponds/default_bob'))));
  test('mais pas sans être connecté', () => assertFails(getDoc(doc(anon, 'ponds/default_bob'))));
  test('chacun crée le sien', () =>
    assertSucceeds(setDoc(doc(bob, 'ponds/default_bob'), { userId: 'bob', name: 'Mon bassin' })));
  test("personne ne crée celui d'un autre", () =>
    assertFails(setDoc(doc(bob, 'ponds/default_carol'), { userId: 'bob', name: 'Pas le mien' })));
  test('nom vide refusé', () =>
    assertFails(updateDoc(doc(alice, 'ponds/default_alice'), { name: '' })));
});

describe('le reste est fermé', () => {
  test('collection inconnue : ni lecture ni écriture', async () => {
    await assertFails(getDoc(doc(alice, 'users/alice')));
    await assertFails(setDoc(doc(alice, 'users/alice'), { userId: 'alice' }));
  });
});

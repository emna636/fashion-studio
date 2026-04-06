# Fashion Studio (Flutter Web + Spring Boot)

Application de gestion d’atelier de couture : **Clients**, **Designs**, **Commandes**, **Paiements**.

- Frontend : **Flutter Web (Material 3)**
- Backend : **Spring Boot + PostgreSQL + JWT**
- Upload photo (Designs) : **Supabase Storage**
- PDF : génération **Proforma / Facture** côté backend

---

## 1) Structure du projet

```
Fashion studio/
  Frontend/   # Flutter
  Backend/    # Spring Boot
```

---

## 2) Pré-requis

### Frontend
- Flutter SDK installé
- Chrome (pour Flutter Web)

### Backend
- Java 17+
- Maven
- PostgreSQL (local ou Supabase Postgres)

---

## 3) Backend (Spring Boot)

### 3.1 Configuration (variables d’environnement)

Le backend **ne contient pas** de mots de passe dans le repo. Configure ces variables :

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET` (au moins 32 caractères)
- `JWT_EXPIRATION_MINUTES` (optionnel)

Exemple PowerShell (Windows) :

```powershell
$env:DB_URL="jdbc:postgresql://aws-0-eu-west-1.pooler.supabase.com:5432/postgres"
$env:DB_USERNAME="postgres.<project_ref>"
$env:DB_PASSWORD="<ton_mot_de_passe>"
$env:JWT_SECRET="CHANGE_ME_SUPER_SECRET_KEY_AT_LEAST_32_BYTES_LONG"
```

### 3.2 Lancer le backend

Depuis :

`Backend/fashion-studio-backend`

```powershell
mvn spring-boot:run
```

Le backend écoute par défaut sur :

- `http://localhost:8080`

---

## 4) Frontend (Flutter Web)

### 4.1 Installer les dépendances

Depuis :

`Frontend/`

```powershell
flutter pub get
```

### 4.2 Variables d’environnement Flutter (`--dart-define`)

Le frontend utilise :

- `API_BASE_URL` (backend)
- `SUPABASE_URL` (si upload photo)
- `SUPABASE_ANON_KEY` (si upload photo)
- `SUPABASE_BUCKET` (ex: `designs`)

Exemple :

```powershell
flutter run -d chrome `
  --dart-define=API_BASE_URL=http://localhost:8080 `
  --dart-define=SUPABASE_URL=https://<project_ref>.supabase.co `
  --dart-define=SUPABASE_ANON_KEY="<anon_key>" `
  --dart-define=SUPABASE_BUCKET=designs
```

---

## 5) Fonctionnalités principales

### 5.1 Clients
- CRUD (ajout / modification / suppression)
- Mensurations

### 5.2 Designs
- CRUD
- **Import photo** (au lieu de saisir une URL)
- Upload dans Supabase Storage, puis sauvegarde de l’`imageUrl` public

### 5.3 Commandes
- CRUD
- Statuts (inclut `PAYE`)

### 5.4 Paiements
- Ajout paiement
- Calcul du reste
- Mise à jour automatique du statut de commande en `PAYE` si montant payé >= total

---

## 6) PDF (Proforma / Facture)

Le backend expose :

- `GET /commandes/{id}/facture.pdf`

Il renvoie :
- une **Proforma** si la commande n’est pas entièrement payée
- une **Facture** si la commande est payée

Le frontend propose un bouton **PDF** dans chaque carte commande pour télécharger.

---

## 7) Supabase Storage (policies RLS)

Si l’upload échoue avec :

> `new row violates row-level security policy`

Ajoute des policies (SQL Editor) pour le bucket `designs` (mode test rapide) :

```sql
create policy "Public read designs"
on storage.objects for select
to public
using (bucket_id = 'designs');

create policy "Public upload designs"
on storage.objects for insert
to public
with check (bucket_id = 'designs');

create policy "Public update designs"
on storage.objects for update
to public
using (bucket_id = 'designs')
with check (bucket_id = 'designs');
```

> Recommandation production : restreindre aux utilisateurs authentifiés.

---

## 8) Notes sécurité

- Ne jamais committer : mots de passe DB, clés privées, fichiers `.env`
- Pour Supabase, évite d’exposer des buckets trop permissifs en production

---

## 9) Dépannage

### Backend ne démarre pas
- Vérifie Java/Maven
- Vérifie `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`

### Upload Supabase 403 / RLS
- Vérifie `SUPABASE_BUCKET=designs`
- Ajoute les policies Storage

---

## 10) Licence

Projet interne / apprentissage.

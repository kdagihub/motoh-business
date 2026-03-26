# MotoH Business

App chauffeur pour gerer son profil, abonnement et visibilite.

## Lancement

```bash
flutter run -d chrome
```

## Backend API (motoh-api)

### Demarrage du serveur

```bash
cd ../motoh-api
go run cmd/api/main.go
```

Le serveur demarre sur `http://localhost:8080`.
En mode dev (`DEV_MODE=true`), les codes OTP sont affiches dans les logs ET retournes dans la reponse JSON.

### Endpoints utilises par l'app chauffeur

| Methode | Endpoint                          | Auth        | Description                              |
|---------|-----------------------------------|-------------|------------------------------------------|
| POST    | `/auth/request-otp`               | Non         | Demande un OTP par SMS                   |
| POST    | `/auth/verify-otp`                | Non         | Verifie l'OTP, retourne un JWT           |
| GET     | `/auth/me`                        | JWT         | Infos de l'utilisateur connecte          |
| PUT     | `/auth/fcm-token`                 | JWT         | Enregistre le token FCM du device        |
| POST    | `/auth/complete-driver-profile`   | JWT         | Cree le profil chauffeur (1ere fois)     |
| GET     | `/drivers/profile`                | JWT+driver  | Consulter son profil                     |
| PUT     | `/drivers/profile`                | JWT+driver  | Modifier son profil                      |
| POST    | `/drivers/location`               | JWT+driver+abo | Met a jour la position GPS            |
| PUT     | `/drivers/status`                 | JWT+driver+abo | Passer en ligne / hors ligne          |
| POST    | `/subscriptions/initialize`       | JWT+driver  | Initier un paiement Paystack             |
| GET     | `/subscriptions/current`          | JWT+driver  | Abonnement en cours                      |
| PUT     | `/subscriptions/auto-renew`       | JWT+driver  | Activer/desactiver le renouvellement     |

> **JWT+driver** = JWT requis + role "driver"
> **JWT+driver+abo** = JWT requis + role "driver" + abonnement actif

### Flux d'authentification

```
1. POST /auth/request-otp
   Body: { "phone": "+2250700000000" }
   Reponse: { "user_id": "xxx", "otp_code": "123456", "message": "OTP sent successfully" }
            (otp_code visible uniquement en DEV_MODE=true)

2. POST /auth/verify-otp
   Body: { "user_id": "xxx", "code": "123456" }
   Reponse: { "token": "eyJ...", "user_id": "xxx", "role": "client" }

3. Utiliser le token dans le header pour tous les appels proteges :
   Authorization: Bearer eyJ...
```

### Flux d'inscription chauffeur (apres authentification)

```
POST /auth/complete-driver-profile
Authorization: Bearer <token>
Body: {
  "full_name": "Kouame Jean",
  "city": "Abidjan",
  "photo": "https://...",
  "identity_document": "https://...",
  "motorcycle_plate": "AB-1234-CI"
}

-> Le role passe de "client" a "driver"
-> Essai gratuit de 7 jours demarre automatiquement
```

### Gestion de la position GPS

```
POST /drivers/location
Authorization: Bearer <token>
Body: { "latitude": 5.3600, "longitude": -4.0083 }

PUT /drivers/status
Authorization: Bearer <token>
Body: { "is_online": true }
```

### Abonnement Paystack

```
POST /subscriptions/initialize
Authorization: Bearer <token>
Body: { "plan": "weekly", "email": "driver@example.com" }
       plan: "weekly" (1000 FCFA) ou "monthly" (4000 FCFA)
       email: optionnel (placeholder genere si absent)

Reponse: {
  "authorization_url": "https://checkout.paystack.com/...",
  "access_code": "...",
  "reference": "motoh_weekly_abc12345",
  "public_key": "pk_test_..."
}

-> Rediriger l'utilisateur vers authorization_url pour payer
-> Le webhook Paystack confirme le paiement automatiquement
```

### Enregistrement du token FCM

```
PUT /auth/fcm-token
Authorization: Bearer <token>
Body: { "fcm_token": "dK7x..." }
```

### Rate limiting

- OTP : 5 requetes/min par IP
- Global : 60 requetes/min par IP

### Base URL pour le dev

```
http://localhost:8080
```

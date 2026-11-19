# Practice 11 — A Real Server

Student: Sagynayev Alimzhan. Thursday 16:00–17:00.

## Wire inspection (curl / PowerShell, real JSONPlaceholder)

| Request | Observed status | Body |
|---|---|---|
| GET /users | 200 | Array of 10 users |
| GET /users/1 | 200 | One user object |
| GET /users/999 | 404 | {} |
| POST /users | 201 | Submitted fields plus id: 11 |
| GET /users?id=3 | 200 | Array containing one object, not an object |

Content-Type: application/json; charset=utf-8.
The original response for user 1 is in test/fixtures/user1.json.

### User fields

| Field | JSON type | Dart type | Nullable in our contract? |
|---|---|---|---|
| id | number (integer) | int | No |
| name | string | String | No |
| username | string | String | No |
| email | string | String | No |
| phone | string | String | No |
| website | string | String? | Yes, missing/null accepted |
| address | object | Address | No |
| company | object | record + companyBs | No |

All sampled users contain these fields. A sample does not prove a server field
will never be absent: required missing/wrong-type fields are rejected as
BadResponseException; only website is deliberately optional.

### Address

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| street | string | String | No |
| suite | string | String | No |
| city | string | String | No |
| zipcode | string | String | No |
| geo | object | Geo | No |

### Geo (nested inside address)

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| lat | string | double via double.parse | No |
| lng | string | double via double.parse | No |

### Company

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| name | string | String in record | No |
| catchPhrase | string | String in record | No |
| bs | string | String (companyBs on User) | No |

The assignment asks for a two-field company record but also a full JSON
round-trip. companyBs preserves the third real field instead of dropping it.
User equality and hashCode use id. Tests also compare toJson maps, so equality
by id cannot hide lost fields. phoneDigits retains digits and +; the raw phone
is preserved for display/serialization.

## Architecture

core/api/api_client.dart owns the injected HTTP client, Accept header,
ten-second timeout, status checking, JSON decoding and debug-only logging.
ClientException is handled as well as SocketException because package:http can
wrap socket failures. AbortableRequest stops the transport when waiting ends:
Future.timeout on its own does not cancel the underlying request.

features/users/user_repository.dart returns User objects and application
exceptions only. It uses Uri.https, maps parsing failures to BadResponseException,
and expects 201 for POST. HTTP status is checked BEFORE JSON parsing.
A 404 {} is NotFoundException, not a misleading parsing failure.

The document contradicts itself: it asks for http.Client() in main.dart but
also exactly two files importing package:http. main.dart uses ApiClient.standard()
to keep the exact two-import boundary while wiring the dependency graph once.

UsersModel owns loading/error/items and saving. It has no BuildContext or
mounted. Disposal closes the client and prevents late notifications.
The screen switches exhaustively on the sealed ApiException hierarchy;
there is no default branch. BadResponseException has no Retry button.

POST inserts the returned user at the top. JSONPlaceholder does not persist
writes: refresh loads the original ten users again. Its repeated id 11 replaces
the previous local id 11 rather than creating duplicate identities.
Blank strings/zero coordinates fill non-form fields in a new-user draft;
they are not claims about a person's real address.

## Verification

The tests cover JSON round-trip, nullable website, phone normalization,
GET/POST shape, 401/404/5xx, malformed JSON, network failures, timeout,
recovery, disabled Save and single POST, error Snackbar, successful insertion,
and disposal while a request is in flight.

## Network measurements

Pending emulator measurement and DevTools captures.

## Run

flutter pub get
flutter run
flutter analyze
flutter test

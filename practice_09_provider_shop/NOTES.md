# Practice 9 Notes

Student: Sagynayev Alimzhan

## Level 1 - lifted state

Adding the total to the badge changed two constructors: `BooksScreen` and
`CartBadge`. The value was passed through `main.dart`, `books_screen.dart`, and
`cart_badge.dart`.

One Add tap rebuilt `BooksScreen` once and all six book rows. The console showed
seven build messages for that tap: one screen message and six row messages.

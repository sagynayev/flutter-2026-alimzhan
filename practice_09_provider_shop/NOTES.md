# Practice 9 Notes

Student: Sagynayev Alimzhan

## Level 1 - lifted state

Adding the total to the badge changed two constructors: `BooksScreen` and
`CartBadge`. The value passed through `main.dart`, `books_screen.dart`, and
`cart_badge.dart`.

One Add tap rebuilt `BooksScreen` once and all six book rows. The console showed
seven build messages for that tap: one screen message and six row messages.

## Provider mistakes

Using `context.watch<Cart>().add(book)` inside `onPressed` produced the loud
error: "Tried to listen to a value exposed with provider, from outside of the
widget tree." A callback must use `read`.

Using `context.read<Cart>().count` in `CartBadge.build` produced no exception.
The badge silently stayed at 0 because `read` does not subscribe the widget.

## Rebuild measurement

With `watch` in the badge, three presses on the quantity plus button printed
`badge build` three times. With `select` on `Cart.count`, the same three presses
printed it zero times. Removing the book changed the count and printed it once.

## Where does it live?

- Cart: provided, because both routes use it and changes must notify listeners.
- Search text: ephemeral, because only the Books screen needs the current query.
- Total expanded/collapsed state: ephemeral, because it belongs to one screen.
- Theme mode: lifted above `MaterialApp`, because it changes the whole app.

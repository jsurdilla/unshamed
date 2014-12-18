To deploy:
1. Add Mandrill API_KEY to Heroku.

TimelineService

Building a user's graph:
Check if the user's timeline exists in cache.
If not


Timeline for all each category:
"cat:anxiety:"
  :feed
  :resources
    - hash
  :members
[[]]
"cat:ocd:"
"cat:supporter:"

User creates a new post/public journal entry:
- Look at user's categories and push the item to that category.

User deletes an existing post/journal entry:
- Look at uesr's categories and remove that item to that category.

User changes the visibility of their journal entries from private to
public:
- Look at user's categories and push the item to that category.

User changes the visibility of their journal entries from public to
private:
- Look at user's categories and push the item to that category.

User changes categories:
- Remove the items from the categories that are no longer in the user's
categories.
- Add the items to the categories thare now in the user's categories.


cat:anxiety:users (LIST)
- users:1
- users:2

New Post
- users:1:feed
- users:2:feed

- users:1 is removed from anxiety
- users:1:feed

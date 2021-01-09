# Boost Responder CC

This is a very simple cc that responds to boosts automatically by sending a custom thank you message, adding a custom reaction to the boost message and optionally giving the booster a specified amount of rep. You can also add your own extra code near the bottom of the cc (area is marked by a comment)

**How does it work?**
It checks the .Message.Type, boost messages have the types 8, 9, 10, 11 which each display a different boost message depending on if the server reached a new boost tier and which one it reached.

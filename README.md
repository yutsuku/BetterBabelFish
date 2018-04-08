Better Bable Fish -- by Zayla of Dethecus
-----------------------------------------

This addon is a re-implementation of an addon called Bable Fish that allows Horde and Alliance to talk with each other.  The way it works is you talk using the commands:
  to talk in "say":  /bf Hi there everyone!
  to talk in "yell":  /bfy Yo, what's up!
Your message will be translated into gibberish and then sent in the "say" or "yell" channels.  The gibberish is special though, and anyone with either the original Bable Fish addon or this improved version will understand what you said regardless if they are Horde or Alliance. 

The original Bable Fish has a few problems:

	1 - With the old version you would see both the original message and the gibberish.  This makes it hard to talk because the gibberish tends to scroll the conversation off the screen.  This addon hides the gibberish so you only see the translations.
	
	2 - With the old version all messages, regardless of faction or say/yell, look the same once translated.  This addon shows them in the same format as other yells and says and also retains the language indicator so that you can easily tell if the speaker is your faction or the other.  Messages are marked with a |BF| or [BF] depending on which version of Bable Fish the speaker is using.
	
	3 - The old version has a few bugs because some the gibberish strings it used would translate form Orkish to Common with non-letter symbols in them.  The result is that a message with symbols such as an equal sign won't translate from Orkish to Horde.  This new addon, works around the problem so that if either speaker or listener (or both) has the new addon then the message will work fine.

Note: This Better Bable Fish is fully compatible with the original Bable Fish.  So if you have it you can talk to people with both this new and the original versions.

*** This new version also understands item links and enchant links.   So if someone uses the new or old version of BF to send you a link, then you will see it and be able to click it.  

If you mouseover someone and have tooltips on then the player's tool tip will show "BabelFish seen." if that playe has ever spoken with BabelFish in your hearing.  

How to use it:

After installing is just type /bf or /bfy followed by your message.  A person with the addon (or the old version) will see what you said, people without the addon will see gibberish.  For example:  "/bf Hi there!" will come out as "OmGwTF hEhE Mc WTF i wtB WTF WTg Kthx OMGWTF".  Since you have have this addon, you won't see the gibberish, you'll just see the translation back to "Hi there!".

Please note that, it is not clear that the translation features are not considered an exploit.  So use them at your own risk!

----------------------------------------------------------------

Changelog Version 2.5 - 

BF now checks incomming item links to make sure they are valid.  Bad
links are stripepd out to prevent you from DC'ing.

Note that recipe links are not checked so use care when clicking them.

You can use %n where n is some number to send a link based on item id.
Item ids can be seen in the URLs of used by WoWHead, Thottbot, and
Blizzard's Armory.  Example: %44 would give a link to Squire's Pants
and %22821 would be a link to Doomfinger.  If you use a bogus id
number or a number for something your server has never seen, it will
come out as "[bogus item id]";

Changelog Version 2.4 - 

BF messages now work in PARTY, RAID, and GUILD chat using /bfp, /bfr,
and /bfg.


Version 2.3 -
Added support for capital letters and the " symbol.

Version 2.2 - 
Added tooltip saying if player has Babel Fish on mouseover.
Target name replaces %t now.

Version 2.1 -
Updated for WoW 2.0.3 patch.

Version 2.0 -
Updated for WoW 2.0 patch.

Version 1.1 -
Added ability to read item links.

Version 1.0 -
Initial version. 



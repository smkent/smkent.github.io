---
layout: post
title: "Automatically asking recruiters for salary range"
slug: recruiter-robot
---

Like many experienced software engineers, I receive a steady stream of email
contacts from recruiters. Most of these emails don't contain important
information such as the compensation range for the role the recruiter is
selling. [Companies who aren't serious about hiring talent][no-labor-shortage]
need to be filtered out to avoid wasting time. To solve this, I set up a script
to automatically reply to recruiter emails asking for the compensation range.

I followed Jeff Carpenter's [**Setting Up a Recruiter Auto-reply
Bot**][original] as a guide to set up automatic replies to recruiters in Gmail
using [Google Scripts][gscripts].

# Reply template

The purpose of the auto reply message is to ask the important questions right
away. Identifying preferences and dealbreakers from the start saves everyone
time.

I wanted the message to clearly identify itself as an automatic reply. For fun,
I decided to personify my template as a robot with its own name. I settled on
this:

> Hi and thanks for reaching out! I'm Stephen's friendly robot, Waffles. Stephen
> receives a high volume of employment opportunities, so I help get his eyes on
> the right ones.
>
> Help me out with the following questions and I'll get your email to Stephen in
> a jiffy!
>
> * What role do you have in mind for Stephen?
> * What is the compensation range and breakdown for this role, such as
>   salary/equity/bonuses/etc.? See Stephen's [LinkedIn page][linkedin] for
>   context or leveling purposes.
> * What is the remote work policy for this role?
> * Does this role require availability outside of business hours? Stephen is
>   based in Seattle, in the Pacific time zone.
> * Does your company require 1) an uncompensated non-compete following
>   employment or 2) mandatory binding arbitration?
>
> Thanks so much!
>
> \- Waffles

# Organizing recruiter emails

I have a Gmail filter that catches most of my recruiter emails into a Recruiters
label. Most recruiters include their title in their email signature, so this
filter simply matches the words "recruiter," "recruiting," "sourcer," or
"sourcing" and applies the label. Once in a while when I get an email that
doesn't match the filter, I just label it manually.

# Script setup

I borrowed [Jeff Carpenter's script][original] as a starting point. I modified
it to use an HTML template that lives with the script for the reply content. I
also set each thread to be archived when sending a reply, to move the initial
recruiter contact emails out of my inbox. Here's my version:

```javascript
// Recruiter auto reply bot
// Adapted from https://www.jeffcarp.com/posts/2019/recruiter-auto-reply-bot/

// Configuration
const LIVE_MODE = false; // @TODO Change to true when ready to deploy
const GMAIL_SEARCH = 'label:Recruiters after:2021/07/04';
const MAX_THREADS = 3;

function init() {
  const myEmail = Gmail.Users.getProfile('me').emailAddress;
  if (!myEmail || myEmail.indexOf('@') === -1) {
    throw new Error('Error fetching my email.');
  }

  // Fetch threads
  var threads = GmailApp.search(GMAIL_SEARCH, 0 /* start */, MAX_THREADS);
  log(`[${myEmail}] fetched ${threads.length} thread(s) matching "${GMAIL_SEARCH}"`);

  threads.forEach(function(thread) {
    const messages = thread.getMessages();
    const firstMessage = messages[0];
    const lastMessage = messages[messages.length-1];

    const threadFrom = firstMessage.getFrom();
    const threadSubject = firstMessage.getSubject();
    const threadDate = firstMessage.getDate();
    const threadAge = daysSince(threadDate, Date.now()) + ' days ago';
    const threadHasReplies = messages.some(function(message) {
      return message.getFrom().indexOf(myEmail) !== -1;
    });
    log(
      `[thread] ${threadHasReplies ? '(skip) ' : ''}` +
      `From "${threadFrom}" [${threadSubject}] -- ` +
      `sent ${threadAge} on ${threadDate}"`
    )
    if (threadHasReplies) {
      // Skip threads where I've already replied to any message.
      return;
    }

    if (!LIVE_MODE) {
      log(`[reply] Would send to ${lastMessage.getFrom()} [${lastMessage.getSubject()}]`);
      return;
    }

    var htmlBody = HtmlService.createHtmlOutputFromFile('reply-template').getContent();
    lastMessage.reply(
      "This is an HTML email message. " +
      "You'll need an email client that understands HTML to read this email.",
      {
        htmlBody: htmlBody,
      }
    );
    log(`[reply] Sent to ${lastMessage.getFrom()} [${lastMessage.getSubject()}]`);

    if (thread.isInInbox()) {
      thread.moveToArchive();
      log(`[archived] Thread from ${lastMessage.getFrom()} [${lastMessage.getSubject()}]`);
    }
  });
}

// ***** Utility functions ***** //

function log(msg) {
  // Log to both Logger and console.
  // Logger for development, console for Stackdriver logging.
  if (LIVE_MODE) {
    Logger.log(msg);
  }
  console.log(msg);
}

// Takes two Unix timestamps in milliseconds.
function daysSince(dateA, dateB) {
  return Math.round(Math.abs((dateA - dateB)/(24*60*60*1000)));
}
```

I then formatted my automatic reply template as HTML, and saved it as an
HTML file within my Google Script project:

```html
<html>
<head></head>
<body>
<p>
Hi and thanks for reaching out! I'm Stephen's friendly robot, Waffles.
Stephen receives a high volume of employment opportunities,
so I help get his eyes on the right ones.<br />
<br />

Help me out with the following questions and I'll get your email
to Stephen in a jiffy!<br />

<ul>
<li>What role do you have in mind for Stephen?
<li>What is the compensation range and breakdown for this role, such as
    salary/equity/bonuses/etc.? See Stephen's <a
    href="https://www.linkedin.com/in/smkent/">LinkedIn page</a> for context or
    leveling purposes.
<li>What is the remote work policy for this role?
<li>Does this role require availability outside of business hours? Stephen is
    based in Seattle, in the Pacific time zone.
<li>Does your company require 1) an uncompensated non-compete following
    employment or 2) mandatory binding arbitration?
</ul>

Thanks so much!<br />
<br />

- Waffles<br />
</p>
</body>
</html>
```

### Deployment

Similar to the original guide, deployment of this script uses these steps:

1. Create a new [Google Scripts][gscripts] project
2. Copy the script code into the editor and modify with any customizations. When
   ready, set `LIVE_MODE` to `true`.
3. Make sure the selected function to run is `init`.
4. Make sure the Gmail API is turned on. Click the "Services +" bar, select
   Gmail from the list, and click Add.
5. Create a new HTML file within the project called `reply-template.html`
6. Copy the HTML reply template into the editor, and change the content to be
   what you want to say to recruiters.
7. Create a time-based trigger to run the script automatically, by clicking
   Triggers in the leftmost navigation list and adding a new trigger. I set mine
   to run once per hour.


[linkedin]: https://linkedin.com/in/smkent
[gscripts]: https://script.google.com
[original]: https://www.jeffcarp.com/posts/2019/recruiter-auto-reply-bot/
[no-labor-shortage]: https://qz.com/2012965/the-us-labor-shortage-is-just-a-wage-shortage/

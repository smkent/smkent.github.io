---
layout: post
title: "Knowing my real-time market value with tech recruiter email automation"
date: 2022-03-13 10:00:00-07:00
tags: compensation employment recruiters tech-industry
---

[As demand for tech workers continues to
escalate][nyt-tech-hiring-crisis-archive], I'm getting more email from tech
recruiters than ever. After simplifying my recruiter email auto-reply message,
I'm collecting even more compensation data. I now have personalized insight into
the real-time price for software engineering talent.

# Old and busted, new hotness

Last year, I created an email auto-reply script that automatically
asks every recruiter who emails me for more information:

{% include linked_post.html url="/2021/recruiter-robot" %}

I recently changed email providers and rewrote my script. I took the opportunity
to simplify the auto-reply message. My old reply message asked recruiters to
answer several questions about the role they're pitching. Now, my deal-breakers
are plainly listed and recruiters are only asked to provide compensation
information.

> Hi! 👋
>
> I'm Stephen's friendly robot, 🧇 Waffles. Stephen receives a high volume of
> employment opportunities, so I help get his eyes on the right ones!
>
> Stephen is open to fully remote roles that offer:
>
> * Strong compensation and benefits
> * Healthy work-life balance (No overtime or on-call)
> * Fair working conditions (No non-compete after employment or mandatory
>   binding arbitration)
>
> If the role you're offering is a fit, I want to pass it along to Stephen! Let
> me know what the total compensation range is for this role, and I'll show
> Stephen your email right away! 📫
>
> Stephen is based in Seattle (Pacific time zone). Read more about Stephen on
> LinkedIn.
>
> Thanks!
>
> \- Waffles
>
> By the way, check out my code 💻 --
> [https://github.com/smkent/waffles][waffles-gh] and
> [https://pypi.org/project/wafflesbot][waffles-pypi]

(I have in-depth opinions on [non-competes][post-non-competes] and [forced
arbitration][post-forced-arbitration].)

# Filtering and auto-replying to initial recruiter emails

My auto-reply script periodically looks at my `Recruiters` email label. The
script then replies to and archives email threads that only have a single
message -- i.e., initial recruiter emails. Email threads with more than one
message are ignored.

I'm now using this filter to automatically apply the `Recruiters` label to
incoming email:

```
{({"recruiting" "recruiter" "sourcing" "sourcer"} -reference -from:linkedin) from:inmail-hit-reply@linkedin.com}
```

`{}` is boolean OR, while `()` is boolean AND. Breaking this filter down, an
email matches if:

* All of these are true:
  * The message does contain any of the specific words "recruiting",
    "recruiter", "sourcing", or "sourcer"
  * The message does not contain the word "reference"
  * The message is not from LinkedIn
* Or, the message is specifically from `inmail-hit-reply@linkedin.com`

## LinkedIn sender addresses

LinkedIn InMails are initially sent from `inmail-hit-reply@linkedin.com`, but
conversation replies are sent from `hit-reply@linkedin.com`. By filtering just
on `inmail-hit-reply@linkedin.com`, I can restrict the auto-reply script to
initial recruiter messages only.

All email from `inmail-hit-reply@linkedin.com` bypasses my inbox.

# Organizing recruiter responses

After recruiters respond to my auto-reply email, the thread reaches my inbox. I
periodically review incoming threads to review roles and compensation data. I
set up a saved search in my email to find only threads where recruiters have
responded to my auto-reply message.

## Email internals

My outgoing recruiter auto-reply emails have a specific [Message-ID][message-id]
format which contains the string `wafflesbot`. For example:

```
Message-ID: <2022.03.10T17.30.03.879344@wafflesbot.example.smkent.net>
```

Email replies contain another header called `References`. This header value
contains `Message-ID`s for all earlier messages in the same thread. That means
when a recruiter responds to my auto-reply, their response email has a
`References` header value that includes my auto-reply message ID:

```
References: <deadbeef1138@mail.example.com> <2022.03.10T17.30.03.879344@wafflesbot.example.smkent.net>
```

In this example, `<deadbeef1138@mail.example.com>` is the `Message-ID` of the
recruiter's initial email.

## Matching thread metadata

Knowing my auto-reply email `Message-ID` format, I can simply search for all
mail with `wafflesbot` in the `References` header value:

```
header:references:wafflesbot
```

In order to reduce the amount of mail to be searched, I also restrict the search
to a date before I deployed the auto-reply script:

```
header:references:wafflesbot after:"Jan 1, 2022"
```

## Adding LinkedIn responses

The previous query covers email to my personal address. I can locate LinkedIn
conversation replies with the following search:

```
from:hit-reply@linkedin.com subject:" message replied: re:"
```

Putting these together, my saved search for all recruiter auto-reply responses
that looks like this:

```
(header:references:wafflesbot after:"Jan 1, 2022") OR (from:hit-reply@linkedin.com subject:" message replied: re:")
```

## Using my saved search as a response queue

I have a second copy of the above saved search for emails still in my inbox:

```
in:inbox (header:references:wafflesbot after:"Jan 1, 2022") OR (from:hit-reply@linkedin.com subject:" message replied: re:")
```

With this I can quickly find the threads I haven't yet replied to or archived.
Once I reply and/or archive a thread, messages disappear from this search filter
until the recruiter responds again.

# Full price discovery

The volume of compensation data I receive in recruiters' responses gives me a
lot of data to work with at any given time. However, recruiter-provided
compensation ranges aren't always what employers are truly willing to pay for
talent.

For roles with compensation ranges around the median or above, I attempt to find
out what the true price for talent is. I ask if a company can meet a certain
compensation floor (assuming other offer components are strong) based on data
Waffles and I have collected. I'm frequently told yes -- meaning the true
compensation range for a given role can extend 20-30% or more above the initial
stated range. In this way, employers are bidding on talent before I even have to
decide whether to pursue any particular opportunity.

For jobs with significantly below market compensation, I let recruiters know
that fact. While recruiters for these roles typically don't reply with a true
market rate adjustment, employers who are below market can be motivated to
adjust their ranges for future candidates if their low compensation prevents
them from hiring the talent they need.

# Transparency helps everyone

With how in-demand tech workers are, many employers struggle to source, hire,
and retain talent. Employers save time and effort when candidates are up front
about their needs, both regarding compensation and otherwise.

Several recruiters have really liked my auto-reply message! Some highlights
include:

> "Good bot!"

> "LOL! This is amazing! What's up Waffles!"

> "Waffles is FANTASTIC!"

# Pursuing worthwhile opportunities

This entire process helps me identify which jobs fit my basic needs. If the role
itself sounds appealing, I continue the conversation and add a separate label to
the thread. I can easily keep track of opportunities that are worthwhile to
pursue!


[message-id]: https://en.wikipedia.org/wiki/Message-ID
[nyt-tech-hiring-crisis-archive]: https://web.archive.org/web/20220307150417/https://www.nytimes.com/2022/02/16/magazine/tech-company-recruiters.html
[post-forced-arbitration]: /2022/forced-arbitration
[post-non-competes]: /2022/non-competes
[waffles-gh]: https://github.com/smkent/waffles
[waffles-pypi]: https://pypi.org/project/wafflesbot

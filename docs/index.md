# Sunlight Congress API

A live JSON API for the people and work of Congress.

## Features

Lots of features and data for members of Congress:

* Look up legislators by location or by zip code.
* Crosswalk for IDs of legislators across various official and 3rd party services.
* Official Twitter, YouTube, and Facebook accounts.
* Committees and subcommittees in Congress, including memberships and rankings.

We also provide Congress' daily work:

* All introduced bills in the House and Senate, and what occurs to them (updated daily).
* Full text search over bills, with powerful Lucene-based query syntax.
* Real time notice of votes, floor activity, and committee hearings, and when bills are scheduled for debate.

All data is served in JSON, and requires a Sunlight API key. An API key is [free to register](http://services.sunlightlabs.com/accounts/register/) and has no usage limits.

We have an [API mailing list](https://groups.google.com/forum/?fromgroups#!forum/sunlightlabs-api-discuss), and can be found on Twitter at [@sunlightlabs](http://twitter.com/sunlightlabs).

## Getting Started

The Sunlight Congress API lives at:

```text
http://congress.api.sunlightfoundation.com
```

There are three types of methods in the Congress API:

**Filter** methods return paginated lists of documents, that can be sorted and filtered by various fields and operators. These methods support partial responses, meaning you can ask just for specific fields. Some large fields must be specifically asked for. Under the hood, these methods use [MongoDB](http://www.mongodb.org/).

**Search** methods can execute a full-text search query, using a Lucene-based query string syntax. Search methods can also do everything that filter methods do - sorting, pagination, filtering, operators, and partial responses. Under the hood, these methods use [ElasticSearch](http://www.elasticsearch.org/).

**Locate** methods look up data by `latitude` and `longitude`, or by a `zip` code. No sorting, pagination, or other filters. Under the hood, these methods use a [modified version](https://github.com/sunlightlabs/pentagon) of the Chicago Tribune's [Boundary Service](https://github.com/newsapps/django-boundaryservice).

All methods are plural, and return arrays of documents. To fetch a single document, filter by that document's unique ID, and look at the first (only) document in the result set.


## Methods

Filter methods:

<table>
<tr>
<td>/legislators</td><td>Current legislators' names, IDs, biography, and social media.</td>
</tr><tr>
<td>/committees</td><td>Current Congressional committees, subcommittees, and their membership.</td>
</tr><tr>
<td>/bills</td><td>Legislation in the House and Senate, back to 2009. Updated daily.</td>
</tr><tr>
<td>/votes</td><td>Roll call votes in Congress, back to 2009. Updated within minutes of votes.</td>
</tr><tr>
<td>/floor_updates</td><td>To-the-minute updates from the floor of the House and Senate.</td>
</tr><tr>
<td>/hearings</td><td>Committee hearings in Congress. Updated as hearings are announced.</td>
</tr><tr>
<td>/upcoming_bills</td><td>Bills scheduled for debate in the future, as announced by party leadership.</td>
</tr>
</table>

Search methods:

<table>
<tr>
<td>/bills/search</td><td>Full-text search of bills' most recent versions, back to 2009. Updated daily.</td>
</tr>
</table>

Locate methods:

<table>
<tr>
<td>/legislators/locate</td><td>Find representatives and senators for a `latitude`/`longitude` or `zip`.</td>
</tr><tr>
<td>/districts/locate</td><td>Find Congressional Districts for a `latitude`/`longitude` or `zip`.</td>
</tr>
</table>

## Bulk Data

Core data for legislators, committees, and bills come from public domain [scrapers](https://github.com/unitedstates/congress) and [bulk data](https://github.com/unitedstates/congress-legislators) at [github.com/unitedstates](https://github.com/unitedstates/). 

The Congress API is not designed for bulk data downloads. Requests are limited to a maximum of 50 per page, and many fields need to be specifically requested. Please use the above resources to collect this data.

## Planned Features

* All amendments to bills introduced in the House and Senate.
* Various relevant documents: 
    * GAO reports, CBO reports, CRS reports, statements of Administration Policy.
    * Full text search over these documents.

## Other APIs

If the Sunlight Congress API doesn't have what you're looking for, check out other Congress APIs:

* [GovTrack Data API](http://www.govtrack.us/developers/api)
* [New York Times Congress API](http://developer.nytimes.com/docs/congress_api)

Or if you're looking for other government data:

* [FederalRegister.gov API](https://www.federalregister.gov/learn/developers) - Official (government-run) API for the activity of the executive branch of the US government. Includes proposed and final regulations, notices, executive orders, and much more.
* [Open States API](http://openstates.org/api/) - US legislative data for all 50 states.
* [Capitol Words API](http://capitolwords.org/api/) - Search speeches of members of Congress (the Congressional Record), and get all sorts of language analysis on frequently used words and phrases.
* [Influence Explorer API](http://data.influenceexplorer.com/api) - Data around federal lobbying, grants, contracts, and state and federal campaign contributions.
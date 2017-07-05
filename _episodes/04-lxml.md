---
title: "Web scraping using Python: requests and lxml"
teaching: 40
exercises: 30
questions:
- "How can scraping a web site be automated?"
- "How can I download web pages' HTML in Python?"
- "How can I evaluate XPath or CSS selectors in Python?"
- "How can I format scraped data as a spreadsheet?"
- "How do I build a scraper that is resilient to change and aberration?"
objectives:
- "Using `requests.get` and resolving relative URLs with `urljoin`"
- "Traversing HTML and extracting data from it with `lxml`"
- "Creating a two-step scraper to first extract URLs, visit them, and scrape their contents"
- "Apprehending some of the things that can break when scraping"
- "Storing the extracted data"
keypoints:
- "`requests` is a Python library that helps downloading web pages, primarily with `requests.get`."
- "`requests.compat.urljoin(response.url, href)` may be used to resolve a relative URL `href`."
- "`lxml` is a Python library that parses HTML/XML and evaluates XPath/CSS selectors."
- "`lxml.html.fromstring(page_source)` will produce an element tree from some HTML code."
- "An element tree's `cssseelct` and `xpath` methods extract elements of interest."
- "A scraper can be divided into: identifying the set of URLs to scrape; extracting some elements from a page; and transforming them into a useful output format."
- "It is important but challenging to be resilient to variation in page structure: one should automatically validate and manually inspect their extractions."
- "A framework like [Scrapy](http://scrapy.org) may help to build robust scrapers, but may be harder to learn."
---

# Recap
Here is what we have learned so far:

* We can use XPath or CSS selectors to select what elements on a page to scrape.
* We can look at the HTML source code of a page to find how target elements are structured and
  how to select them.
* We can use the browser console to try out XPath or CSS selectors on a live site.
* We can use visual scrapers to handle some basic scraping tasks. These help determine an appropriate selector, and may be able to navigate through a web site collecting data.

This is quite a toolset already, and it's probably sufficient for a number of use cases, but there are
limitations in using the tools we have seen so far.
For example, some data may be structured in ways that are too out of the ordinary for visual scrapers, perhaps requiring items to be processed only in certain conditions.
There may also be too much data, or too many pages to visit, to simply run the scraper in a web browser, as some visual scrapers operate.
Writing a scraper in code may make it easier to maintain and extend, or to incorporate quality assurance and monitoring mechanisms.

# Introducing Requests and lxml

We make use of two tools that are not specifically developed for scraping, but are very useful for that purpose (among others).

[Requests](http://docs.python-requests.org/en/latest/) focuses on the task of interacting with web sites.
It can download a web page's HTML given its URL.
It can submit data as if filled out in a form on a web page.
It can manage cookies, keeping track of a logged-in session.
And it helps handling cases where the web site is down or takes a long time to respond.

[lxml](http://lxml.de) is a tool for working with HTML and XML documents, represented as an *element tree*.
It evaluates XPath and CSS selectors to find matching elements.
It facilitates navigating from one element to another.
It facilitates extracting the text, attribute values or HTML for a particular element.
It knows how to handle badly-formed HTML (such as an opening tag that is never closed, or a closing tag that is never opened), although it may not handle it identically to a particular web browser.
It is also able to construct new well-formed HTML/XML documents, element by element.

To use CSS selectors, the [cssselect](https://pypi.python.org/pypi/cssselect) package must also be installed.

Both of these require a Python installation (Python 2.7, or Python 3.4 and higher; although our example code will focus on Python 3),
and each library (requests and lxml and cssselect) needs to be installed as described in [Setup]({{page.root}}/Setup).
If they are correctly installed, it should be possible to then write the following Python code without an error occurring:

~~~
>>> import requests
>>> import lxml
>>> import cssselect
~~~
{: .source}

We will be working in Python. Open a text editor or IDE (such as Spyder) to edit a new file, saved as `unsc-scraper.py`.
Check that you can run the file with Python, e.g. by running the following in a terminal:

~~~
$ python unsc-scraper.py
~~~
{: .source}

If `unsc-scraper.py` is empty, this should run but not output anything to the terminal.

## Downloading a page with requests

Let's start by downloading the page of UNSC resolutions for 2016.  Enter the following in your file and save:

~~~
import requests

response = requests.get('http://www.un.org/en/sc/documents/resolutions/2016.shtml')
print(response.text)
~~~
{: .python}

You should see the same as what you would when using a web browser's _View Source_ feature (albeit less colourful):

```
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=8" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Resolutions adopted by the United Nations Security Council since 1946</title>
...
```
{: .output}

What's it doing?

* `import requests` has made the requests library available to your Python code.
* `requests.get(URL)` tries to request the URL from the web server and returns a `Response` object which includes various details about the request and its response.
* `response.text` reads all the content sent back by the web server (and raises an error if the request was unsuccessful), in this case HTML source code.

We now have the page content, but as a string of textual characters, not as a tree of elements.

## Traversing elements in a page with lxml

The following illustrates loads the response HTML into a tree of elements, and illustrates the `xpath` and `cssselect` methods provided on an ElementTree (and each Element thereof), as well as other tree traversal.
Running the following code:

~~~
import requests
import lxml.html

response = requests.get('http://www.un.org/en/sc/documents/resolutions/2016.shtml')
tree = lxml.html.HTML(response.text)
title_elem = tree.xpath('//title')[0]
title_elem = tree.cssselect('title')[0]  # equivalent to previous XPath
print("title tag:", title_elem.tag)
print("title text:", title_elem.text_content())
print("title html:", lxml.html.tostring(title_elem))
print("title tag:", title_elem.tag)
print("title's parent's tag:", title_elem.getparent().tag)
~~~
{: .python}

produces this output:

~~~
title tag: title
title text: Resolutions adopted by the United Nations Security Council in 2016
title html: b'<title>Resolutions adopted by the United Nations Security Council in 2016</title>&#13;\n'
title tag: title
title's parent's tag: head
~~~
{: .output}

This code begins by building a tree of Elements from the HTML using `lxml.html.fromstring(some_html)`. It then illustrates some operations on the elements.
With some element, `elem`, or the tree:

* `elem.xpath(some_path)` and `elem.cssselect(some_selector)` find a list of nodes relative to `elem` matching the given XPath or CSS selector expression, respectively.
* `elem.getparent()` gets the parent element of `elem`. Similarly, `elem.getprevious()` and `elem.getnext()` may return a single element, or None.
* `elem.getchildren()` gets a list of the children of `elem`, while `elem.getiterator()` allows for iterating over all the descendants of `elem`. (Not illustrated above.)
* `elem.tag` is `elem`'s tag name.
* `elem.text_content()` gets the text of an element and all of its children
* `elem.attrib` is a dict of the attributes of `elem`.
* `lxml.html.tostring(elem)` translates the element back into HTML/XML.

In the above example, we extract the first (and only) `<title>` element from the page, show its text, etc., and do the same for its parent, the `<head>` node.
When we print the text of that parent node, we see that it consists of two blank lines. Why?

Apart from basic features of Python, these are all the tools we should need.

> ## Beautiful Soup, an alternative library to access a tree of HTML elements
> [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/)
> (or bs4) provides similar functionality to lxml and is
> commonly used for web scraping. It does not, however, support XPath.
> We also found it gave us worse results when our target web site had errors in
> its HTML (using the `html.parser` backend). In some ways, Beautiful
> Soup may have a more friendly design for web scraping (e.g. its handling
> of text).
{: .callout}

# UNSC scraper overview

Now that we have some idea of what requests and lxml do, let's use them to scrape UNSC data.
We will modularise our scraper design as follows:

1. A `get_year_urls` function will return a list of year URLs to scrape resolutions from.
2. A function `get_resolutions_for_year` will return an object like `{'date': '1962', 'symbol': 'S/RES/174 (1962)', 'title': 'Admission of new Members to the UN: Jamaica', 'url': 'http://www.un.org/en/ga/search/view_doc.asp?symbol=S/RES/174(1962)'}` for each resolution at the given page URL.
3. The scraper script will run `get_year_urls`, and then `get_resolutions_for_year` for each year and write the resolutions in CSV to the file `unsc-resolutions.csv`.

# Spidering pages of UNSC resolutions

We'll start by compiling a list of URLs to scrape. We will write a Python function called `get_year_urls`. Its job is to get the set of URLs listing resolutions, which we will later scrape.

For a start, the following function will extract and return a list of the URLs linked to from the starting page:

~~~
def get_year_urls():
    start_url = 'http://www.un.org/en/sc/documents/resolutions/'
    response = requests.get(start_url)
    tree = lxml.html.fromstring(response.text)
    links = tree.cssselect('a')  # or tree.xpath('//a')

    out = []
    for link in links:
        # we use this if just in case some <a> tags lack an href attribute
        if 'href' in link.attrib:
            out.append(link.attrib['href'])
    return out
~~~
{: .python}

Calling this function and printing its output should produce something like the following:

~~~
print(get_year_urls())
~~~
{: .python}

~~~
["#mainnav", "#content", "http://www.un.org/en/index.html", "/ar/sc/documents/resolutions/", …, "http://undocs.org/rss/scdocs.xml", "2010.shtml", "2011.shtml", …]
~~~
{: .output}

We are faced with two issues:

1. We only want to get the year-by-year resolutions listings, and should ignore the other links.
2. Only the URLs starting with `http://` can directly be passed into `requests.get(url)`. The others are termed *relative URLs* and need to be modified to become *absolute*.

> ## Dealing with relative URLs
>
> Most of the URLs found in `href` attributes are _relative_ to the page we found them in. We could
> prefix all those URLs with `http://www.un.org/en/sc/documents/resolutions/`
> to make them absolute, but that doesn't handle all the cases.
> Since this is a common need, we can use an
> existing function, `requests.compat.urljoin(base_url, relative_url)` which will translate:
>
> | From relative URL                | To absolute URL                                           |
> |----------------------------------|-----------------------------------------------------------|
> | `#mainnav`                       | `http://www.un.org/en/sc/documents/resolutions/#mainnav`  |
> | `2010.shtml`                     | `http://www.un.org/en/sc/documents/resolutions/2010.shtml`|
> | `/ar/sc/documents/resolutions/`  | `http://www.un.org/ar/sc/documents/resolutions/`          |
> | `http://www.un.org/en/index.html`| `http://www.un.org/en/index.html` (unchanged)             |
>
> Here, the `base_url` is something like `"http://www.un.org/en/sc/documents/resolutions/2010.shtml"` and the relative URL is something like `"#mainnav"`.
> However, beware: the base URL is not always identical to the URL you pass into `requests.get(url)` for two reasons:
>
> * When you got the URL it may have redirected you to a different page. URLs are therefore relative to the response URL, stored in `response.url`, rather than the request URL. For example, `requests.get("http://www.un.org/ar/sc/documents/resolutions").url` returns `"http://www.un.org/ar/sc/documents/resolutions/"`. Note that this subtly, but importantly, adds a `"/"` at the end.
> * The HTML on a page can indicate that the base for its relative URLs is something else. (See [W3Schools on `<base>`](https://www.w3schools.com/tags/tag_base.asp).) That is, if `tree.xpath('//head/base@href')` returns something, you should use its first value as the base URL. This does not apply in our case because there is no `<base>` tag in the page we are scraping.
>
> (A Python scraping framework, [Scrapy](https://scrapy.org/), recently introduced a way to avoid some of these pitfalls, using `response.follow`. This is not applicable when using `requests` and `lxml` directly.
{: .callout}

> ## Challenge: Get absolute URLs for year pages
>
> Complete the `get_year_urls` by function fixing the two issues listed above: it should resolve the relative URLs and only get URLs corresponding to yearly resolution listings.
>
> > ## Solution
> > We use a more specific CSS selector, along with `urljoin`:
> >
> > ~~~
> > def get_year_urls():
> >     """Return a list of (year_url, year) pairs
> >     """
> >     start_url = 'http://www.un.org/en/sc/documents/resolutions/'
> >     response = requests.get(start_url)
> >     tree = lxml.html.fromstring(response.text)
> >     links = tree.cssselect('#content > table a')
> >
> >     out = []
> >     for link in links:
> >         year_url = urljoin(response.url, link.attrib['href'])
> >         out.append(year_url)
> >
> >     return out
> > ~~~
> > {: .python}
> >
> > The following describe alternative solutions:
> >
> > 1. Use the same CSS selector as above (`a`), but filter the URLs for those that look like they end in a number followed by `.shtml`.
> > 2. Generate all the URLs without downloading the start page, by simply counting from 1946 to the current year, which can be found with `import datetime; datetime.datetime.now().year`.
> > 3. Use a different CSS selector for the same content (e.g. `table a` or `td > a`).
> {: .solution}
{: .challenge}

In the final version of `get_year_urls`, we make a couple of modifications, to ensure we're getting what we want, and to return the year number along with the URL (by getting it from `link.text_content()`):

~~~
def get_year_urls():
    """Return a list of (year_url, year) pairs
    """
    start_url = 'http://www.un.org/en/sc/documents/resolutions/'
    response = requests.get(start_url)
    tree = lxml.html.fromstring(response.text)
    tables = tree.cssselect('#content > table')
    # Check you captured something and not more than you expected
    if len(tables) != 1:
        print('Expected exactly 1 table, got {}'.format(len(tables)))
        return []

    table = tables[0]
    links = table.cssselect('a')

    out = []
    for link in links:
        year_url = urljoin(base_url, link.attrib['href'])
        year = link.text_content()
        # TODO: validate that year is actually an appropriate number
        out.append((year_url, year))

    # Check we got something
    if not out:
        print('Expected some year URLs, got none')
    return out
~~~
{: .python}

In this implementation, we first extract the `<table>` element, roughly make sure it's what we want, and then apply a CSS selector to get the content within it.

It's a good idea to check you're getting the kind of data you expect, because:

* If we get no tables (perhaps because the page wasn't retrieved correctly), then `tables[0]` will fail, raising an error that stops the entire scraper. In a large scraping operation, this could halt lots of work in progress.
* If we get more tables than 1, we should review that we've got the right data. Maybe the web site's owners have changed how the page is structured and put some other part of the page in a table which our CSS selector then inadvertently captures.
* If we get no year URLs, then we've failed our task.

Here we just use `print` output as a way to report if something went wrong.

> ## Advanced challenge: Validate `year`
> If the page changes and the year text is not a valid number, we'd like to know about that.
> Write code that validates the year text as being a four-digit number, and does not add a year with invalid text to `out`.
>
> > ## Solution
> > Insert at the TODO above:
> > ~~~
> > if len(year) != 4 or not year.isdigit():
> >     print("Link text '{}' is not an integer".format(link.text_content()))
> >     continue
> > ~~~
> > {: .python}
> {: .solution}
{: .challenge}

> ## When the URLs to scrape can't be listed
> Sometimes you can list the pages needed to be scraped in advance. Here we can just generate URLs for all years from 1946 until now.
> Often building a scraper involves analysing the kinds of URLs on a web site and constructing a list of them programmatically.
>
> On the other hand, sometimes you cannot get all the URLs at once, for instance when you need to click a "next page" link (although sometimes these URLs can also be enumerated by identifying patterns in the next page URLs). This means you can't design your scraper with distinct "collect URLs" and "scrape each URL" phases. Instead you might _add each URL to a queue for later processing_. (A scraping framework like Scrapy manages this queuing for you.)
{: .callout}

We have a list of year pages to scrape. Now we need to scrape the resolutions off each year page.

# Scraping a page of UNSC resolutions

At the heart of `get_resolutions_for_year` is getting a record (a row in the output CSV) for each resolution that contains its details.
Looking at [2016](http://www.un.org/en/sc/documents/resolutions/2016.shtml), we want:

* `symbol`: the text of the first column
* `url`: the link `href` attribute from the first column
* `date`: the text of the second column
* `title`: the text of the third column

However, for earlier years such as [1999](http://www.un.org/en/sc/documents/resolutions/1999.shtml), the date column is not provided, and we want:

* `symbol`: the text of the first column
* `url`: the link `href` attribute from the first column
* `date`: the year determined from `get_year_urls`
* `title`: the text of the second column

We have a few choices in how to code this up, too:

1. Match all the symbols with one CSS selector evaluated over the document; match all the titles with another selector; merge them together.
2. Match all the symbols' elements with one CSS selector, then iterate over its subsequent sibling elements to get the other fields.
3. Match all the row elements with one CSS selector, then use a CSS selector within it to get each field.
4. Match all the row elements with one CSS selector, then use the element's `.getchildren(...)` to get each field's `<td>` element.

We will take the last approach. Let's assume that the code for extracting `table` is basically the same as in `get_year_urls`:

~~~
import requests
import lxml.html

def get_resolutions_for_year(year_url, year):
    """Return a list of resolutions

    Each should be represented as a dict like::

        {'date': ..., 'symbol': ..., 'url': ..., ''title': ..., }
    """
    response = requests.get(year_url)
    tree = lxml.html.fromstring(response.text)
    tables = tree.cssselect('#content > table')
    # Check you captured something and not more than you expected
    if len(tables) != 1:
        print('Expected exactly 1 table, got {}'.format(len(tables)))
        return []
    table = tables[0]
    out = []

    for row_elem in table.cssselect('tr'):
        resolution = {}
        # TODO: extract data for each resolution
        out.append(resolution)

    # Check we got something
    if not out:
        print('Expected some resolutions, got none'.format(year))
    return out


# Test get_resolutions_for_year on 2016
resolutions = get_resolutions_for_year("http://www.un.org/en/sc/documents/resolutions/2016.shtml", "2016")
for resolution in resolutions:
    print(resolution)
~~~
{: .python}

We added:

* a loop over each row, being a `<tr>` element;
* some code at the end to test if our scraper-in-progress is working.

> ## Limit the number of URLs to scrape through while debugging
>
> Eventually, we want our scraper to apply its extraction to all pages of UNSC resolutions.
> But while we're working through to the final code that will allow us
> the extract the data we want from those pages, we only want to run it on one
> or a few pages at a time.
>
> This will not only run faster and allow us to iterate more quickly between different
> revisions of our code. It will also not burden the server too much while we're debugging.
> This is probably not such an issue for only tens of pages, but it's good
> practice, as it can make a difference for larger scraping projects. If you are planning
> to scrape a massive website with thousands of pages, it's better to start small. Other
> visitors to that site will thank you for respecting their legitimate desire to access
> it while you're debugging your scraper...
>
> If you have a list of URLs to scrape, such as the output from `get_year_urls()`,
> you might simply slice that list.
> In Python, lists can be _sliced_ using the `list[start:end]` where `start` and `end` are numbers, either of which can be left out:
>
> ~~~
> list[start:end] # items from start through end-1
> list[start:]    # items from start through the rest of the array
> list[:end]      # items from the beginning through end-1
> list[:]         # all items
> ~~~
> {: .source}
>
> Thus `list[:5]` will get the first five elements from `list`.
{: .callout}


The TODO above needs to be filled in with code to get the HTML elements corresponding to `symbol`, `date` (where present) and `title`, and extracting their text.

Running that script as it is will download the page and print an empty dict for each resolution:

~~~
{}
{}
{}
{}
{}
{}
{}
...
~~~
{: .output}

Let's start filling in the TODO above, extracting the symbol text for each resolution:

~~~
        children = row_elem.getchildren()
        resolution['symbol'] = children[0].text_content()
~~~
{: .python}

This gets the first child of the row, i.e. its first cell, extracts its text, and places it in the resolution dict with the key `"symbol"`. Run the script and check the output. We see:

~~~
{'symbol': 'Resolutions adopted by the Security Council \r\n      in 2016'}
{'symbol': 'S/RES/2336 \r\n      (2016)'}
{'symbol': 'S/RES/2335 \r\n      (2016)'}
{'symbol': 'S/RES/2334 \r\n      (2016)'}
{'symbol': 'S/RES/2333 \r\n      (2016)'}
{'symbol': 'S/RES/2332 \r\n      (2016)'}
{'symbol': 'S/RES/2331 \r\n      (2016)'}
~~~
{: .output}

> ## Challenge: Identify two issues in that output
> There are two problems in the output above. What are they?
>
> > ## Solution
> > 1. The header has been included.
> > 2. The symbols surprisingly have `" \r\n      "` in them.
> {: .solution}
{: .challenge}

## Cleaning the symbols

We can exclude the header with:

~~~
        if len(children) == 1:
            # Assume that a row with 1 element is the header
            continue
~~~
{: .python}

Another approach would be to replace `table.cssselect('tr')` with `table.cssselect('tr')[1:]` to ignore the first row returned by the selector.

To clean up the messy symbols, we have to realise that `"\r\n"` are special in Python: they indicate a line break (like pressing enter) in text. So what we have here is a sequence of _white-space characters_ including `"\r"`, `"\n"`, and `" "`. In HTML, a sequence of white-space characters is usually interpreted as a single space. The following substitutes a single space for any white-space sequence in retrieving an element's text.

~~~
def clean_text(element):
    all_text = element.text_content()
    cleaned = ' '.join(all_text.split())
    return cleaned
~~~
{: .python}

Make these two changes and run the script again to check it's working better.

## Extracting other fields

We can handle the fact that a date column may or may not be present with:

~~~
        if len(children) == 3:
            # there is a date column
            resolution['date'] = clean_text(children[1])
        elif len(children) == 2:
            # adopt the year for the page
            resolution['date'] = year
        else:
            print('Unexpected number of children in row element: {}'.format(len(children)))
            continue
~~~
{: .python}

Run this on 2016 and 1999 to check that the output is sensibly getting 'symbol' and 'date' whether or not the date column is available.

> ## Challenge: fill in the `title` and `url` fields
>
> The URL extraction requires finding the `<a>` element within the symbol cell and extracting its attribute, as in `get_year_urls` above.
>
> The title text can be extracted like the other fields, except that it is sometimes the second and sometimes the third (but always the last) column.
>
> Hint: You can get the last element of a Python list with `[-1]`. The CSS selectors `:nth-last-child(1)` and `:nth-last-of-type(1)` fulfill a similar purpose.
>
> > ## Solution
> > ~~~
> >         symbol_links = children[0].cssselect('a')
> >         if len(symbol_links) != 1:
> >             print('Expected 1 link in the symbol column, got {}'.format(len(symbol_links)))
> >             continue
> >         relative_url = symbol_links[0].attrib['href']
> >         resolution['url'] = requests.compat.urljoin(response.url, relative_url)
> >         resolution['title'] = clean_text(children[-1])
> > ~~~
> > {: .python}
{: .challenge}

# Putting it all together

All we appear to need now is write some code to call `get_resolutions_for_year` for each year, and use Python's standard `csv` module to change our dicts into CSV. This code can replace the "Test get_resolutions_for_year on 2016" code and drive the overall scraper.

~~~
import csv
import time

with open('unsc-resolutions.csv', 'w') as out_file:
    writer = csv.DictWriter(out_file, ['date', 'symbol', 'title', 'url'])
    writer.writeheader()

    # Loop over years
    for year_url, year in get_year_urls():
        time.sleep(0.1)  # Wait a moment

        print('Processing:', year_url)
        year_resolutions = get_resolutions_for_year(year_url, year)

        for resolution in year_resolutions:
            writer.writerow(resolution)
~~~
{: .python}

Some explanation:

* `with open(...) as out_file` opens a file for writing and calls it `out_file`. Using `with` ensures that the file is closed, whether the `with` block is ended by completion or by error.
* `csv.DictWriter(...)` constructs a writer which converts dicts with the specified fields to a comma-delimited table (CSV) and writes it to `out_file`.
* `writer.writeheader()` writes the line `date,symbol,title,url` at the top of the CSV.
* `for year_url, ...` begins to iterate over the year URLs acquired from `get_year_urls()`.
* `time.sleep(0.1)` instructs Python to wait for 10% of a second before downloading the next page. This helps to avoid placing too much strain on the `www.un.org` web server.
* `print('Processing', ...)` tells you which year the scraper is scraping. It is very valuable to have this knowledge when you need to work out why some other error message was printed.
* `year_resolutions = ...` gets the resolutions for the current year in the loop.
* `writer.writerow(resolution)` converts the resolution to a line of CSV and outputs it.

You have a full scraper. But does it perfectly capture the data?

## Quirks and quality assurance

Run the above scraper. Do our `print` statements highlight any quirks in the web site?

Open the output (`unsc-resolutions.csv`) in a spreadsheet program like Microsoft Excel. Can you identify any other quirks from the data?

> ## Challenge: debug the issues
> Your scraper should have reported:
>
> * "Expected 1 link in the symbol column, got 0" in [2013](http://www.un.org/en/sc/documents/resolutions/2013.shtml);
> * "Expected exactly 1 table, got 2" in [1964](http://www.un.org/en/sc/documents/resolutions/1964.shtml) and [1960](http://www.un.org/en/sc/documents/resolutions/1960.shtml); and
> * "Expected some resolutions, got none" in [1959](http://www.un.org/en/sc/documents/resolutions/1964.shtml).
>
> View those pages (you should not need to view the source) to identify the associated issues: how are those pages different from the ones you initially designed your scraper for?
> Then fix the scraper to get the complete, clean dataset.
>
> > ## Solution
> > 1. 2013 has a header row above the data. Because our scraper already skips the row when there is no link in it, the data is clean. We could modify our scraper to silence the error in this year:
> >    ~~~
> >    if len(symbol_links) != 1:
> >        if year != '2013':
> >            print('Expected 1 link in the symbol column, got {}'.format(len(symbol_links)))
> >        continue
> >    ~~~
> >    {: .python}
> > 2. 1964 and 1960 have the page duplicated!
> >
> >    Replace:
> >    ~~~
> >    if len(tables) != 1:
> >        print('Expected exactly 1 table, got {}'.format(len(tables)))
> >        return []
> >    ~~~
> >    {: .python}
> >    With:
> >    ~~~
> >    if not tables:
> >        print('Expected 1 table, got none')
> >        return []
> >    if len(tables) > 1:
> >        print('Taking first of {} tables'.format(len(tables)))
> >        return []
> >    ~~~
> > 3. Our system correctly identifies that there are no resolutions in 1959. We could modify our scraper to silence the error in this year:
> >    ~~~
> >    if year != '1959':
> >        print('Expected some resolutions, got none'.format(year))
> >    ~~~
> >    {: .python}
> {: .solution}
{: .challenge}

In constructing this lesson, we identified several quirks in the data, where one year differed from another in surprising ways (and there may be more we have not identified!). We have discussed many of these:

* In the [index page](http://www.un.org/en/sc/documents/resolutions/), most links to year pages have relative URLs like `1980.shtml`, but some are like `/en/sc/documents/resolutions/2015.shtml`. Without `urljoin` we could have easily made a mistake finding the page URLs.
* Some years have a date column, while most do not.
* One year has a header row, giving names describing each column, while others do not.
* Two years duplicate the entire page's HTML. If we had not checked for the case of extracting multiple tables, we might only have noticed the issue from the data, perhaps by plotting the counts per year and seeing an outlying count in 1960, or by noticing duplicate records.
* In some years, such as [2017](http://www.un.org/en/sc/documents/resolutions/), not all `<tr>` opening tags have a matching `</tr>` closing tag. At one time we also found an excess `</tr>`. Alternatives to lxml may behave differently with such errors. Python's `html.parser` simply ignored the rest of the page's content when it reached the excess `</tr>`, discarding subsequent resolution data.
* White-space in the resolution symbols differs from year to year. We found: `"S/RES/1939  (2010)"` vs. `"S/RES/2025 (2011)"` vs. `"S/RES/2132\n       (2013)"`

These quirks are somewhat peculiar to web sites that are _manually edited_. However, similar things can happen with database-backed web sites. For instance:

* some fields may be absent, causing your XPath/CSS selectors to return empty or capture the wrong piece of data;
* the HTML may differ for different categories of object (e.g. films vs. TV shows);
* historical data may not be presented like recent data;
* the template may change between different runs of the scraper; or
* the web site may return an error page, or may identify your scraper as malicious and refuse to continue serving you content.

> ## Tips for quirk resilience
> Here are some tips about how you could ensure that your scraper will work despite variation.
>
> 1. Look at your scraped data. Look at it more closely. Look at random samples collected over time. Perhaps analyse it in a tool like OpenRefine which will show you the number of distinct/duplicated values in each column. If you are scraping data over a long time, keep a dashboard of diagnostic measures to show you how many fields come back blank, for instance.
> 2. Think about cases where your scraper might fail, and apprehend them in code. Validate the extractions in your code. When something differs from expectation, output an informative message onto a log. Make sure the log includes enough information about the context, e.g. which page or part of the page you are scraping at the time.
> 3. Only allow an error to halt your scraping operation if that's really necessary, by wrapping your main scraper code in an exception handler. For example:
>    ~~~
>            print('Processing:', year_url)
>            try:
>                year_resolutions = get_resolutions_for_year(year_url, year)
>            except Exception:
>                # the exception has been caught instead of Python exiting
>                print('ERROR while processing', year, ':')
>                import traceback
>                traceback.print_exc()  # describe the error and what code triggered it
>                continue  # skip to the next year
>    ~~~
>    {: .python}
>    Consider this a last resort: if an error occurs, any resolutions scraped from the error year will not be output.
> 4. Write helper functions to make cleaning and error identification easy for you. `clean_text` is one example. Another useful helper might be:
>    ~~~
>    def extract_one(list_of_extractions, default=None):
>        if len(list_of_extractions) == 0:
>            print('Expected some extractions, but got None')
>            return default
>        if len(list_of_extractions) > 1:
>            print('Expected 1 extraction, but got {}'.format(len(list_of_extractions)))
>        return list_of_extractions[0]
>    ~~~
>    {: python}
>    As well as alerting you to more than one extraction, this avoids triggering an error if your `cssselect` or `xpath` query returns an empty list.
>
> A specialised framework like Scrapy helps manage tasks like logging, diagnostics, and handling empty lists of extractions.
{: .callout}

## Using the data

> ## Challenge: Analyse the data
>
> Perform some interesting analysis of the data, for instance:
>
> * Plot the number of resolutions per year. Are there interesting periods of increase or lull?
> * Count how often each title occurs.
> * Identify which words are most frequent in the titles.
> * Plot only those resolutions that pertain to membership vs those that do not.
> * Plot only those resolutions mentioning some country of choice (e.g. Israel or Pakistan) in their title.
> * Very advanced: lookup strings of capitalised words (optionally including lowercase words like "of" and "for") in the Wikipedia or Wikidata API to associate the names with locations. Plot them on a map!
>
> A Pivot Table will be very useful for performing these analyses in Excel or Google Sheets. Similar functionality is provided in Python by [Pandas](http://pandas.pydata.org) and its `pivot` and `groupby` functionality.
{: .challenge}

> ## Extension challenge: multilingual UNSC resolutions
> Run the scraper on resolutions in Arabic (start at http://www.un.org/ar/sc/documents/resolutions/) or Chinese (start at http://www.un.org/zh/sc/documents/resolutions/) and merge the results with English to have columns `en_title`, `ar_title`, etc.
>
> Hint: a tool for tabular data, [`pandas`](http://pandas.pydata.org) can read in CSV (`pandas.read_csv`) and can merge together multiple tables on the basis of some matching keys (`pandas.concat`).
{: .challenge}

While here we have extracted data that was already in tables into another tabular format, very often what we're processing doesn't look like a table on the web site. But the procedure is the same: identify the elements that you wish to extract, and apply a pattern which selects them from the HTML.

You are now ready to write your own scrapers!

# Advanced topics and resources

Aside from ethical questions addressed in the next episode, below are a number of advanced topics related to building a web scraper.  Most are features of existing specialised scraping frameworks, such as Scrapy, or commercial scraping tools.

* __Caching and offline scraping__:
  If you are expecting to scrape the same page many times, for instance while designing and debugging your scraper, it may be a good idea to download part or all of the web site to your own computer in advance of scraping it, so that you do not need to make repeated requests to the web server. Not only does this reduce the load on the web server, but it means the scraping is limited only by the speed of your scraper, not the speed at which you download the data. Some scraping frameworks may offer such caching out of the box; otherwise this involves using one of many existing tools to download a local copy of some web site, or writing the `requests` part of your scraper as a separate process that saves the pages in a database or files on your machine.
* __Scraping many pages at once__:
  Some pages cannot be scraped until another is done. For instance, you may not be able to scrape a listing of resolutions until you know that page exists by looking at the index page.
  But in many cases, multiple pages can be scraped at the same time (as long as doing so does not make too many requests to the same server in a short period). Doing so can make the scraping process faster.
  Scraping frameworks may offer the ability to process pages _in parallel_ (or _asynchronously_).
  If you take advantage of this feature, make sure to be careful how you log messages about issues with the scrape, or it might be hard to tell which page it came from.
* __Periodic scraping__:
  One of web scraping's benefits is its ability to collect data from some web site as it changes over time (assuming the page content changes, but not the page structure). Scrapers can be set up to run periodically.
* __Running the scraper on the cloud__:
  You may not want to leave your own computer on to scrape. It may take resources away from your work, for instance. Commercial scrapers offer to run your scraper on their machines. A free alternative is [morph.io](http://morph.io) which offers to host your open-source scraper in the cloud and return the data to you.
* __Alternative output formats__: Some structures of information are not suitable to put into a table; others are too big to store in a single table. Scraping frameworks may support storing the scraped data in a database or some other structure.
* __Data only accessible through interaction__: Sometimes a web site requires logging in, or you only get access to the data by clicking on or scrolling down the page.  While particular cases may be engineered with a traditional `requests`-based scraper, an alternative is to employ a _web driver_. This is a web browser that is controlled by a program instead of a human, and will naturally run scripts associated with a web page, but can also do things like clicking, scrolling, etc. Emulating a human's interactions can give your scraper access to everything a human can get. The [Web Scraping Sandbox, toscrape.com](http://toscrape.com/) includes several variants of the same artificial web site, including with login forms and "infinite scroll"s that require this kind of scraper. Challenge yourself to scraping the data on that site!

> ## So why didn't we learn Scrapy?
> Scrapy provides a great framework for designing, implementing and managing robust and efficient scrapers. However, we get the sense that people who are not very experienced at programming find the declarative paradigm facilitated by Scrapy very foreign.
>
> On the other hand, writing a more *procedural* scraper as we have here with the nuts and bolts of `requests` and `lxml` helps to motivate some of the issues that Scrapy endeavours to solve or ameliorate.
{: .callout}

# Reference

* [requests documentation](http://docs.python-requests.org/en/master/)
* [lxml documentation](http://lxml.de/api.html)
* [Scrapy documentation](https://scrapy.org/)

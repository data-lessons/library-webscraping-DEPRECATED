---
layout: page
title: Setup
permalink: /setup/
---

# Google Chrome requirements

For the episode on visual scraping in your web browser, the following are required:

* [Google Chrome for Desktop](https://www.google.com/chrome/browser/desktop/)
* [Web Scraper extension](http://chrome.google.com/webstore/detail/web-scraper/jnhgnonknehpejjnehehllkliplmbmhn): click _Add to Chrome_

# Python requirements

We will be using [Anaconda][anaconda] for the episode on scraping in Python, as it includes all of the necessary
requirements. If you don't wish to install Anaconda, you will need to install each requirement
separately. This document only details installation with Anaconda. 

Please set up your Python environment prior to the workshop.  If you encounter problems with the
installation procedure, ask your workshop organizers via e-mail for assistance, so you are ready
to go when the workshop begins.

**Recommended:**

* [Anaconda](#anaconda)

Optional (already provided with Anaconda):

* [Python 3.x](#python)
* [Spyder 3](#spyder)
* [lxml](#lxml): a recent version
* [cssselect](#cssselect)
* [Requests](#reqeusts)

<a name="anaconda"></a>

## Installing all requirements using Anaconda 

[Python][python] is a great language for general-purpose programming, and it even has tools 
available that help with web scraping. Installing each of the additional tools for this lesson 
individually can be a bit difficult, so we recommend the all-in-one installer [Anaconda][anaconda].

Regardless of how you choose to install it, please make sure you install Python version 3.x 
(e.g., Python 3.6 version).

### Windows - [Video tutorial][video-windows]

1. Open [http://continuum.io/downloads][continuum-windows] with your web browser.

2. Download the Python 3.x version installer for Windows.

3. Double-click the executable and install Python 3 using _MOST_ of the default settings. 
   The only exception is to check the **Make Anaconda the default Python** option.

### macOS - [Video tutorial][video-mac]

1. Open [http://continuum.io/downloads][continuum-mac] with your web browser.

2. Download the Python 3.x version Graphical Installer for macOS.

3. Install Python 3 using all of the defaults for installation.

### Linux

Note that the following installation steps require you to work from the shell. 
If you run into any difficulties, please request help before the workshop begins.

1.  Open [http://continuum.io/downloads][continuum-linux] with your web browser.

2.  Download the Python 3.x version installer for Linux.

3.  Install Python 3 using all of the defaults for installation.

    a.  Open a terminal window.

    b.  Navigate to the folder where you downloaded the installer

    c.  Type

    ~~~
    $ bash Anaconda3-
    ~~~
    {: .bash}

    and press tab.  The name of the file you just downloaded should appear.

    d.  Press enter.

    e.  Follow the text-only prompts.  When the license agreement appears (a colon
        will be present at the bottom of the screen) hold the down arrow until the 
        bottom of the text. Type `yes` and press enter to approve the license. Press 
        enter again to approve the default location for the files. Type `yes` and 
        press enter to prepend Anaconda to your `PATH` (this makes the Anaconda 
        distribution the default Python).

## Optional installation method

If you've opted to install the requirements separately (not recommended), you will find links to 
them below.

* <a name="python"></a> [Python 3.x][python-install]
* <a name="spyder"></a> [Spyder 3][spyder-install]
* <a name="lxml"></a> [lxml][lxml-install]
* <a name="cssselect"></a> [cssselect][cssselect-install]
* <a name="requests"></a> [Requests][requests-install]

With [Miniconda](https://conda.io/miniconda.html) for Python 3 installed, the following can be entered on the terminal command line to install all of the required packages:

~~~
conda install spyder lxml cssselect requests
~~~
{: .bash}

## Starting Python

We will use the [Spyder IDE][spyder], the same IDE used in the Library Carpentry Python course. 
If you installed Python using Anaconda, Spyder is already on your system.

To start Spyder, open a terminal and type the command:

On Windows and Linux:

~~~
$ spyder
~~~
{: .bash}

On Mac:

~~~
$ spyder3
~~~
{: .bash}

[anaconda]: https://www.continuum.io/anaconda
[continuum-windows]: http://continuum.io/downloads#windows
[continuum-mac]: http://continuum.io/downloads#macos
[continuum-linux]: http://continuum.io/downloads#linux
[python-install]: https://www.python.org/downloads/
[spyder-install]: https://pythonhosted.org/spyder/installation.html
[lxml-install]: http://lxml.de/installation.html
[cssselect-install]: https://pypi.python.org/pypi/cssselect
[requests-install]: http://docs.python-requests.org/en/master/user/install/#install
[python]: https://python.org
[spyder]: https://pythonhosted.org/spyder/
[spyder-install]: https://pythonhosted.org/spyder/installation.html
[video-mac]: https://www.youtube.com/watch?v=TcSAln46u9U
[video-windows]: https://www.youtube.com/watch?v=xxQ0mzZ8UvA

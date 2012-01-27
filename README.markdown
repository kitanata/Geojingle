GeoJingle is geospatial business intelligence tool used to provide transparent access to eTech data sets in a geospatial format - that is through a mapping technology. The mapping technology that we leverage to accomplish this, Google Maps, allows us to display and manage all kinds of data.

![GeoJingle in the raw](https://github.com/etechAdmin/GeoJingle/raw/master/tutorial/overview.png)

Design Choices
==============

GeoJingle makes the complex easy!
-----------------------------
Our #1 design goal while designing GeoJingle was to make what are typically complex GIS operations easy. We strive for the ability of GeoJingle to answer nearly any question that can be thrown at it. 

A few examples of these include:

* Displaying point data within specific geopolitical region.
    * High Schools in Franklin County
    * Libraries in Senate District 22
    * STEM Organizations inside Columbus City School District

* Filtering point data by numerical or categorical means
    * Filter High Schools by grant participation / ITC
    * Filter School Districts by ISP coverage
    * Filter Counties by funding / population

* Scaling and colorizing data sets based on numeric or categorical data (Future Feature)
    * Show all High Schools in Blue / Elementary Schools in Pink and / Middle Schools in Green
    * Show all Schools but scale the size of the point based on the average classroom size
    * Color school districts based on student performance / Standardized Testing percentile
    * Color senate districts along political representation (Red / Blue)

GeoJingle is 100% data driven!
---------------------------
This means that any updates to software only supply new features dealing with how data is managed rather than the specific types of data in the system. Adding new data sets do not require a change in code or a new deployment.

GeoJingle is Fast!
----------------------
GeoJingle follows the principal of least loaded, also known as "Just-In-Time". This means that GeoJingle doesn't try to load data that you don't care about and only loads exactly what you need, when you need it. GeoJingle caches everything. Once GeoJingle loads something into the browser it stays there until you restart GeoJingle or clear your browser's cache. This means that if you ever have to load a lot of data, loading just a bit more won't take nearly as long.

GeoJingle is Open Source.
----------------------
Project GeoJingle *IS* open source software but is wholly owned by eTech Ohio Commission, a State of Ohio agency. 

It is tri-licenced under the Mozzila Public License(MPL 1.1) version 1.1, the
Gnu General Public License 2.0(GPL2) and the Lesser Gnu General Public License(LGPL 2.1).

```
***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The GeoJingle project is subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use any content of the GeoJingle project
* except in compliance with the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is the "GeoJingle Project".
*
* The Initial Developer of the Original Code is "eTech Ohio Commission".
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*      Raymond E Chandler III
*
* Alternatively, the contents of this project may be used under the terms of
* either the GNU General Public License Version 2 or later (the "GPL"), or
* the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */
```

Tutorial and Walkthrough
==================
* [GUI Overview](GeoJingle/wiki/Tutorial "Tutorial")
* [Registering a new Account](GeoJingle/wiki/Registering-a-new-Account "Registering a new Account")
* [The Menu Bar](GeoJingle/wiki/The-menu-bar "The Menu Bar") 
* [The Tool Bar](GeoJingle/wiki/The-tool-bar "The Tool Bar")
* [The Filter Tool Bar](GeoJingle/wiki/The-filter-tool-bar "The Filter Tool Bar")
* [Working With Filters](GeoJingle/wiki/Working-with-filters "Working with filters")
* [Understanding the Filter Tree](GeoJingle/wiki/Understanding-the-filter-tree "Understanding the Filter Tree")
* [Drilling down with Reduce Filters](GeoJingle/wiki/Reducing-your-data "Reducing your data")
* [Changing Display Properties](GeoJingle/wiki/Changing-display-properties "Changing Display Properties")

eGFR-Study-Criteria-Ruby-Script
===============================

This script connects to a MySQL database with a table of eGFR results (egfr_results) and of the following format:

<code>
`NHSNo` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `DOB` datetime NOT NULL,
  `Sex` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `EG` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `DR` datetime NOT NULL,
  `GP` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Postcode` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Sodium` int(11) NOT NULL,
  `Potassium` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Urea` float NOT NULL,
  `GFRE` int(11) NOT NULL,
  `CREAT` int(11) NOT NULL,
  KEY `NHSNo` (`NHSNo`) USING HASH,
  KEY `DR` (`DR`) USING BTREE,
  KEY `Postcode` (`Postcode`) USING HASH,
  KEY `eGFR` (`GFRE`) USING BTREE
</code>

script creates a results table of records which match the study criteria

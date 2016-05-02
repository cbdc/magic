<?xml version="1.0" ?>
<resource>
  <schema>magic_scs</schema>
  <meta name="title">MAGIC/PIC database of spectra and publications</meta>
  <meta name="description">None</meta>
  <meta name="facility">MAGIC</meta>
  <meta name="shortName">MAGIC publications</meta>
  <meta name="creationDate">2015-12-15</meta>
  <meta name="subject">Gamma rays: galaxies</meta>
  <meta name="subject">Gamma rays: stars</meta>
  <meta name="subject">Gamma rays: galaxies: clusters</meta>
  <meta name="referenceURL">http://vobs.magic.pic.es/fits/</meta>
  <meta name="source">http://vobs.magic.pic.es/fits/</meta>
  <meta name="coverage.waveband">Gamma-rays</meta>
  <meta name="instrument">MAGIC</meta>
  <meta name="type">Catalog</meta>
  <table id="main" mixin="//scs#q3cindex" onDisk="True">
    <index columns="ra,dec"/>
    <column name="object" type="text" ucd="meta.id;meta.main"/>
    <column name="ra" unit="deg" ucd="pos.eq.ra;meta.main"/>
    <column name="dec" unit="deg" ucd="pos.eq.dec;meta.main"/>
    <column name="frequency" unit="Hz"/>
    <column name="delta_frequency" unit="Hz"/>
    <column name="flux" unit="erg / (cm2 s)"/>
    <column name="delta_flux" unit="erg / (cm2 s)"/>
    <column name="upper_limit" type="smallint"/>
    <column name="date" type="text"/>
    <column name="article" type="text"/>
  </table>
  <data id="import">
    <sources>data/table_all.dat</sources>
    <columnGrammar topIgnoredLines="4">
      <colDefs>
      	OBJECT:1-18
      	ra:19-32
      	dec:33-46
      	energy:47-64
      	Denergy:65-82
      	flux:83-100
      	Dflux:101-118
      	upper_limit:119-130
      	DATE_OBS:131-141
      	article:142-194
      </colDefs>
    </columnGrammar>
    <make table="main">
      <rowmaker idmaps="*">
        <map dest="object">@OBJECT</map>
        <map dest="frequency">@energy</map>
        <map dest="delta_frequency">@Denergy</map>
        <map dest="delta_flux">@Dflux</map>
        <map dest="date">@DATE_OBS</map>
        <var name="article">str('href=')+@article+str('')</var>
      </rowmaker>
    </make>
  </data>
  <service allowed="scs.xml,form,static" id="cone">
    <meta name="shortName">magic cone</meta>
    <meta name="testQuery">
      <meta name="ra">49.95</meta>
      <meta name="dec">41.51</meta>
      <meta name="sr">0.1</meta>
    </meta>
    <dbCore queriedTable="main">
      <FEED source="//scs#coreDescs"/>
    </dbCore>
    <publish render="scs.xml" />
    <publish render="form" sets="local"/>
    <outputTable>
      <LOOP>
        <listItems>
          object ra dec frequency flux delta_frequency delta_flux date article
        </listItems>
        <events>
          <outputField original="\item"/>
        </events>
      </LOOP>
      <outputField original="article">
        <formatter><![CDATA[
          urlclean = data[10:]
          yield T.a(href="http://%s"%urlclean , target="_blank")["link"]
        ]]></formatter>
      </outputField>
    </outputTable>
  </service>
</resource>

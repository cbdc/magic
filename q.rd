<resource schema="magic">

  <!--                                                                        -->
  <!--  Resource's metadata: here is how the world get to know your dataset.  -->
  <!--                                                                        -->
  <meta name="title">MAGIC test</meta>
  <meta name="description">
    The MAGIC project observes the VHE sky (GeV~TeV) through Cherenkov radiation events.
    The project is operating since 2004 and with the support from the Spain-VO team
    they provide data access through a VO-SSAP and web services.
    Our goal here is to provide the same kind of service with the difference
    that the data is transformed and homogeneized in its flux units, to values
    in 'erg/(s.cm2)', and photon energy values in equivalent 'Hz' frequency values.
  </meta>
  <meta name="creationDate">02-02-2016</meta>
  <meta name="subject">Spectra</meta>
  <meta name="subject">VHE sources</meta>
  <meta name="subject">Gamma-ray emission</meta>

  <meta name="creator.name">___</meta>
  <meta name="contact.name">___</meta>
  <meta name="contact.email">___</meta>
  <meta name="instrument">___</meta>
  <meta name="facility">MAGIC</meta>

  <meta name="source">
    The MAGIC data center, http://magic.pic.es/
  </meta>
  <meta name="contentLevel">Research</meta>
  <meta name="type">Catalog</meta>

  <meta name="coverage">
    <meta name="waveband">Gamma-ray</meta>
    <meta name="profile">AllSky ICRS</meta>
  </meta>


  <!-- =============== -->
  <!--  Table block    -->
  <!-- =============== -->

  <table id="main" onDisk="True">
    <mixin
      fluxCalibration="ABSOLUTE"
      fluxUnit="erg/(s.cm**2)"
      fluxUCD="phot.flux.density;em.freq"
      spectralUnit="Hz"
      spectralUCD="em.freq"
      > //ssap#hcd
    </mixin>
    <column name="ssa_reference"
            type="text"
            tablehead="Reference"/>
    <column name="reference_doi"
            type="text"
            tablehead="DOI"
            verbLevel="30"/>
  </table>


  <table id="spectrum">
    <mixin
      ssaTable="main"
      fluxDescription="Absolute Flux"
      spectralDescription="Frequency"
      > //ssap#sdm-instance
    </mixin>
    <column name="fluxerror"
            ucd="stat.error;phot.flux.density;em.freq">
      <values nullLiteral="-999"/>
    </column>
    <column name="ssa_timeExt">
      <values nullLiteral="-999"/>
    </column>
  </table>


  <!-- =============== -->
  <!--  Data block     -->
  <!-- =============== -->

  <data id="import">

    <sources pattern='data/*.fits' recurse="True" />

    <fitsProdGrammar hdu="1" qnd="False">
      <rowfilter procDef="//products#define">
        <bind name="table">"\schema.data"</bind>
      </rowfilter>
      <rowfilter name="addSDM">
				<code>
					yield row
					baseAccref = os.path.splitext(row["prodtblPath"])[0]
					row["prodtblAccref"] = baseAccref+".vot"
					row["prodtblPath"] = row["prodtblAccref"]
					row["prodtblMime"] = "application/x-votable+xml"
					yield row
				</code>
			</rowfilter>
    </fitsProdGrammar>

    <make table="main">
      <rowmaker idmaps="*">
        <map key="reference_doi">@REFDOI</map>
        <apply name="fixMissingTelescop">
          <code>
            try:
              @instrument = @TELESCOP
            except:
              @instrument = 'MAGIC'
            try:
              @specstart = @EMIN
            except:
              @specstart = 50
            try:
              @specend = @EMAX
            except:
              @specend = 1000
            try:
              @timeext = @TOBS
            except:
              @timeext = None
          </code>
        </apply>
        <apply procDef="//ssap#setMeta" name="setMeta">
          <bind name="pubDID">\standardPubDID</bind>
          <bind name="dstitle">@OBJECT+'_'+@EXTNAME+'_'+@DATE</bind>
          <bind name="targname">@OBJECT</bind>
          <bind name="alpha">@RA</bind>
          <bind name="delta">@DEC</bind>
          <bind name="dateObs">@DATE_OBS</bind>
          <bind name="bandpass">"Gamma-ray"</bind>
          <bind name="specstart">@specstart</bind>
          <bind name="specend">@specend</bind>
          <bind name="timeExt">@timeext</bind>
          <bind name="length">@NAXIS2</bind>
        </apply>
        <apply procDef="//ssap#setMixcMeta" name="setMixcMeta">
          <bind name="instrument">@instrument</bind>
          <bind name="creator">@AUTHOR</bind>
          <bind name="reference">@REFPAPER</bind>
        </apply>
      </rowmaker>
    </make>

  </data>


  <data id="build_sdm_data" auto="False">

    <embeddedGrammar>
      <iterator>
        <setup>
          <code>
            from gavo.utils import pyfits
            from gavo.protocols import products
          </code>
        </setup>
        <code>
          fitsPath = products.RAccref.fromString(
          self.sourceToken["accref"]).localpath
          hdu = pyfits.open(fitsPath)[1]
          for row in enumerate(hdu.data):
            yield {"spectral": row[1][0], "flux": row[1][2], "fluxerror": row[1][3]}
        </code>
      </iterator>
    </embeddedGrammar>

    <make table="spectrum">
      <parmaker>
        <apply procDef="//ssap#feedSSAToSDM"/>
      </parmaker>
    </make>

  </data>


  <!-- =============== -->
  <!--  Service block  -->
  <!-- =============== -->

  <service id="web" defaultRenderer="form">
    <meta name="shortName">Magic Web</meta>
    <meta name="title">Magic Public Spectra Web Interface</meta>

    <publish render="form" sets="local"/>

    <dbCore queriedTable="main">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="ssa_dateObs"/>
    </dbCore>

    <outputTable>
      <autoCols>
        ssa_targname, accref, mime, ssa_dateObs, ssa_reference,
        ssa_specstart, ssa_specend, ssa_timeExt, ssa_instrument, ssa_length
      </autoCols>
      <FEED source="//ssap#atomicCoords"/>
      <outputField original="ssa_specstart" displayHint="displayUnit=m"/>
      <outputField original="ssa_specend" displayHint="displayUnit=m"/>
      <outputField original="ssa_reference" select="array[ssa_reference,reference_doi]">
        <formatter><![CDATA[
          lbl = data[0]
          url = data[1]
          yield T.a(href="%s"%url , target="_blank")["%s"%lbl]
        ]]></formatter>
      </outputField>
    </outputTable>

  </service>

  <service id="ssa" allowed="ssap.xml">
    <meta name="shortName">Magic SSAP</meta>
    <meta name="title">Magic Public Spectra SSAP Interface</meta>
    <meta name="ssap.dataSource">observation</meta>
    <meta name="ssap.creationType">archival</meta>
    <meta name="ssap.testQuery">MAXREC=1</meta>

    <publish render="ssap.xml" sets="ivo_managed"/>

    <ssapCore queriedTable="main">
      <FEED source="//ssap#hcd_condDescs"/>   <!-- Do we have an option for ssap#mixc? Make sense?! -->
    </ssapCore>

  </service>

</resource>

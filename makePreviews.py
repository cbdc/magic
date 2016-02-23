from gavo.helpers import processing

class PreviewMaker(processing.SpectralPreviewMaker):
    linearFluxes = True
    sdmId = "build_sdm_data"

if __name__=="__main__":
    processing.procmain(PreviewMaker, "magic/q", "import")


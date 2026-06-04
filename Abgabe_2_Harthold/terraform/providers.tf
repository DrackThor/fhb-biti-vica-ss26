# Der Exoscale Provider liest EXOSCALE_API_KEY und EXOSCALE_API_SECRET aus den GitHub Secrets.
# Dadurch werden Zugangsdaten niemals in Git committet.
provider "exoscale" {}

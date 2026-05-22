# exoscale-vm-info

Automatisiertes Setup einer Ubuntu VM auf Exoscale, die einen HTTP Endpoint bereitstellt,
der technische VM-Details liefert.

## Schnellstart
1. Repo klonen
2. `terraform.tfvars` aus `terraform.tfvars.example` erstellen und anpassen
3. GitHub Secrets setzen: `EXOSCALE_API_KEY`, `EXOSCALE_API_SECRET`
4. Push nach GitHub, Workflows ausführen oder lokal `terraform init` / `terraform apply`

## Dateien
- main.tf, provider.tf, variables.tf, outputs.tf
- cloudinit.yaml startet einen Flask Service auf Port 80
- .github/workflows enthält Create und Destroy Workflows

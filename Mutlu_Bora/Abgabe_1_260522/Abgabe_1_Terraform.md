# Terraform

## Was ist Terraform?

Terraform ist ein Tool, mit dem man Infrastruktur nicht mehr per Hand in irgendwelchen Web-Oberflächen zusammenklickt, sondern in Textdateien beschreibt. Man sagt also nicht mehr „klick auf 'Create VM', wähle Ubuntu, 2 CPUs, 4 GB RAM", sondern man schreibt das einfach hin und Terraform macht den Rest. Genau deshalb fällt es auch unter den Begriff Infrastructure as Code (IaC) – die Infrastruktur wird wie ganz normaler Code behandelt: man legt sie in Git ab, macht Code-Reviews und kann jederzeit nachvollziehen, wer wann was geändert hat.

Entwickelt wurde Terraform von HashiCorp, einem US-Unternehmen, das mittlerweile (seit Februar 2025) zu IBM gehört. Die Sprache, in der man die Konfigurationen schreibt, heißt HCL (HashiCorp Configuration Language) und ist relati leicht zu lesen, auch ohne viel Vorwissen.

## Wo wird das eingesetzt?

Terraform taucht überall dort auf, wo Leute mit Cloud oder größeren IT-Umgebungen arbeiten. Klassische Einsatzgebiete sind:

- **Cloud-Ressourcen aufsetzen** – VMs, Datenbanken, Netzwerke, Load Balancer bei AWS, Azure, GCP usw.
- **On-Premise-Virtualisierung** – auch Sachen wie VMware vSphere oder Proxmox kann Terraform verwalten.
- **DevOps / CI-CD** – in Pipelines, wo bei jedem Merge automatisch Test-Umgebungen hoch- und wieder runtergefahren werden.
- **Kubernetes & Co.** – Cluster und sogar einzelne Kubernetes-Ressourcen lassen sich damit verwalten.

Damit man Terraform besser einordnen kann, hier ein kurzer Vergleich mit ähnlichen Tools:

| Tool             | Wer macht's     | Sprache       | Was kann's gut?                     |
|------------------|-----------------|---------------|-------------------------------------|
| **Terraform**    | HashiCorp / IBM | HCL           | Multi-Cloud-Provisionierung         |
| **OpenTofu**     | Linux Foundation| HCL           | Open-Source-Fork von Terraform      |
| **Ansible**      | Red Hat / IBM   | YAML          | Konfiguration *innerhalb* von Systemen |
| **Pulumi**       | Pulumi Corp.    | TypeScript, Python, Go … | IaC mit „echten" Programmiersprachen |
| **CloudFormation** | AWS           | YAML / JSON   | Nur für AWS                         |

Wichtig ist der Unterschied zu **Ansible**: Ansible kümmert sich eher darum, was *auf* einem Server passiert (Pakete installieren, Configs schreiben), während Terraform den Server überhaupt erst *anlegt*. Die beiden kombiniert man in der Praxis oft.

## Wie funktioniert Terraform technisch?

Der typische Ablauf besteht aus vier Befehlen:

1. **`terraform init`** – Lädt die sogenannten *Provider* runter. Das sind kleine Plugins, die wissen, wie man mit AWS, Azure, GitHub etc. redet.
2. **`terraform plan`** – Schaut sich an, was im Code steht und was in der Realität schon existiert. Dann zeigt es einen Plan: „Ich würde 3 neue Sachen anlegen, 1 ändern, 2 löschen."
3. **`terraform apply`** – Macht's wirklich. Ruft im Hintergrund die APIs der Cloud-Anbieter auf.
4. **`terraform destroy`** – Räumt alles wieder ab. Sehr praktisch für Test-Umgebungen.

### Die State-Datei

Ein wichtiger Punkt, der einen am Anfang verwirren kann, ist die State-Datei (`terraform.tfstate`). Da merkt sich Terraform, welche Ressource im Code zu welcher echten Ressource in der Cloud gehört. Ohne diese Datei würde Terraform nicht wissen, dass die VM mit der ID `i-0abc123` zu dem Block `resource "aws_instance" "web"` im Code gehört.

Im Team legt man diese Datei meistens nicht lokal ab, sondern z. B. in einem S3-Bucket ode in Terraform Cloud, damit alle dasselbe „Gedächtnis" haben.

### Provider und Module

- **Provider** sind die Verbindungen zu den Zielsystemen. Es gibt mittlerweile über 4000 davon – AWS, Azure, GCP, Kubernetes, GitHub, Cloudflare, Datadog, Hetzner, Proxmox usw.
- **Module** sind wiederverwendbare Bausteine. Man schreibt z. B. einmal ein Modul „komplettes Netzwerk-Setup für ein Projekt" und nutzt es dann in mehreren Projekten.

### Architektur grob skizziert mit KI

```
┌──────────────┐   plan/apply   ┌────────────┐
│  HCL-Code    │  ────────────▶ │ Terraform  │
│ (*.tf-Files) │                │    CLI     │
└──────────────┘                └─────┬──────┘
                                      │
                        ┌─────────────┼──────────────┐
                        ▼             ▼              ▼
                  ┌──────────┐ ┌──────────┐ ┌──────────────┐
                  │  State   │ │ Provider │ │   Registry   │
                  │  (lokal/ │ │ Plugins  │ │ (Provider +  │
                  │  remote) │ │          │ │   Module)    │
                  └──────────┘ └─────┬────┘ └──────────────┘
                                     │ HTTPS / API
                                     ▼
                         ┌─────────────────────┐
                         │  Ziel-Infrastruktur │
                         │  AWS / Azure / GCP  │
                         │  vSphere / K8s / …  │
                         └─────────────────────┘
```

## Mini-Beispiel

So sieht eine einfache HCL-Datei aus, die eine EC2-Instanz auf AWS hochfährt:

```hcl
provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"

  tags = {
    Name = "vica-demo"
  }
}
```

Nach `terraform init && terraform apply` läuft die VM. Mit `terraform destroy` ist sie wieder weg.

## Das OpenTofu-Drama

Ein Punkt, den man 2026 nicht mehr weglassen kann: Im August 2023 hat HashiCorp die Lizenz von Terraform geändert – weg von der offenen Mozilla Public License, hin zur **Business Source License (BSL)**. Die BSL erlaubt zwar weiterhin den normalen Gebrauch, schränkt aber kommerzielle „Konkurrenz-Angebote" ein. Das hat in der Community ziemlichen Ärger ausgelöst.

Daraus entstand OpenTofu, ein Community-Fork, der seit Januar 2024 produktionsreif ist. OpenTofu wird mittlerweile von der Linux Foundation getragen und ist seit April 2025 ein Projekt der CNCF (Cloud Native Computing Foundation). Der CLI-Befehl heißt dort `tofu` statt `terraform`, ansonsten ist die Bedienung aber fast identisch.

Für die meisten Studierenden- und Hobbyprojekte spielt der Lizenz-Streit keine Rolle, aber für Firmen ist das durchaus ein Thema.

## Stärken und Schwächen

Was Terraform gut macht:
- Funktioniert mit fast allem (Multi-Cloud, On-Prem, SaaS).
- Infrastruktur kommt in Git → versionierbar, reviewbar, reproduzierbar.
- Riesiges Ökosystem an Providern und fertigen Modulen.

Was schwierig sein kann:
- Die State-Datei ist sensibel – wenn die kaputt geht, hat man Stress.
- HCL ist eingeschränkt, sobald man komplexe Logik braucht.
- Wenn jemand manuell in der Cloud-UI was ändert, entsteht *Drift* und Terraform meckert.

## Fazit

Terraform ist quasi der Standard, wenn es um Infrastructure as Code geht, und ein guter Einstiegspunkt, um zu verstehen, wie moderne Cloud-Umgebungen verwaltet werden. Mit OpenTofu gibt's daneben eine vollwertige Open-Source-Alternative, die je nach Firma oder Projekt sogar die bessere Wahl sein kann. Wer einmal `terraform apply` ausgeführt und gesehen hat, wie aus ein paar Zeilen Text eine komplette Cloud-Umgebung entsteht, versteht relativ schnell, warum das Konzept so populär geworden ist.

## Quellen

- HashiCorp: Terraform Documentation – https://developer.hashicorp.com/terraform/docs
- OpenTofu Project – https://opentofu.org/docs/
- Spacelift Blog: *Terraform License Change* – https://spacelift.io/blog/terraform-license-change
- Scalr: *OpenTofu vs Terraform (2026)* – https://scalr.com/learning-center/opentofu-vs-terraform
- Platform Engineering: *Terraform vs OpenTofu* – https://platformengineering.org/blog/terraform-vs-opentofu-iac-tool
- Wikipedia: *OpenTofu* – https://en.wikipedia.org/wiki/OpenTofu

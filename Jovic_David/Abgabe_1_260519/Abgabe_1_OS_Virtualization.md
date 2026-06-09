# OS Virtualization

Auch OS-Level-Virtualization, Containarization, oder auf Deutsch Container-Virtualisierung genannt. Dient dazu Applikationen auf einem Umgebungsbetriebssystem (Host) mit den minimal notwendigen Vorraussetzungen atomar zu verpacken und isoliert auszuführen. Benötigte Ressourcen neben der Physikalischen Schicht ein Betriebsystem, Binaries, Libaries und Runtimes.

Mit der Containervirtualisierung werden viele Probleme beseitigt, welche traditionelle Virtuelle Maschienen aufzeigen. Virtuelle Maschinen im herkömmlichen Sinne, verbrauchen meist viele Ressourcen, da sie ein ganzes Betriebssystem emulieren. Bei der Containervirtualisierung wird stattdessen ein gemeinsames Host-Betriebssystem (auch in einer VM möglich) als Basis für die Containerisierung von Applikationen verwendet. Dadurch wird die Ausführung ressourcenfreundlicher, schneller und leichtgewichtiger.  
  


Container-Virtualisierung kann sowohl auf Linux als auch auf Windows bereit gestellt werden. Jedoch wird Windows eher selten dafür benutzt, da die meiste Software in Containern für Linux geschrieben ist. Der Linux-Kernel vom Host wird bei der OS-Virtualisierung gemeinsam für alle Container genutzt und isoliert sie durch zwei eingebaute Kernfunktionen: **namespaces** und **cgroups**. Durch diese Funktionen wird bei dieser Form der Virtualisierung neben der Isolierung sichergestellt, dass die zugewiesenen Ressourcen(CPU, Speicher, Netzwerk,..) nicht überschritten und ohne spürbaren Leistungsverlust eingesetzt werden können.  
![Kernel Namespaces and Cgroups](https://www.baeldung.com/wp-content/uploads/sites/2/2020/11/Linux-Container-Architecture-1.jpg)

Während Namespaces und Cgroups die isolationstechnischen Grundlagen im Linux-Kernel bereitstellen, bedarf es einer Container Engine (wie Docker), um diese Ressourcen effizient zu verwalten. Sie fungiert als Abstraktionsschicht, die Anwenderbefehle entgegennimmt und die automatische Konfiguration der Kernel-Features steuert.




## Kernkomponenten der OS-Virtualisierung
**Namespaces (Logische Isolation):**

Sie sorgen für die strikte Trennung der Systemressourcen auf Kernel-Ebene. Namespaces isolieren die Sichtbarkeit von Prozessbäumen (PID), Netzwerkschnittstellen(net), Dateisystem-Mounts(mnt) und Hostname(uts). Der Container interagiert dadurch ausschließlich mit seinen eigenen Prozessen und hat keinen Einblick in die Infrastruktur des Hosts oder anderer Container.

**Cgroups (Control groups):**

Sie steuern und begrenzen den Zugriff auf die physische Hardware. Über Cgroups wird exakt festgelegt, wie viel CPU-Leistung, Arbeitsspeicher (RAM) und Festplatten-I/O ein Container maximal beanspruchen darf. Das sichert die Stabilität des Gesamtsystems, da eine einzelne fehlerhafte Anwendung nicht die Ressourcen des gesamten Host-Servers erschöpfen kann.

**Container Networking (Bridge):**

Ermöglicht die Kommunikation der isolierten Instanzen. Dafür wird meist automatisch ein virtuelles Bridge-Netzwerk erzeugt. Jeder Container erhält über virtuelle Schnittstellenpaare (veth-pairs) eine eigene interne IP-Adresse(eth0 -> docker0 -> veth). Dadurch können Container isoliert untereinander kommunizieren oder gezielt einzelne Ports nach außen freigeben.

**Container Engine:**

Dient zur administrativen Verwaltung (mit Docker oder Podman). Da die manuelle Konfiguration von Namespaces, Cgroups und Routings im Linux-Terminal hochkomplex ist, übernimmt die Engine diese Orchestrierung. Sie liest das Container-Image, weist den Kernel an, die Isolationsebenen zu erstellen, und baut die Netzwerkstruktur auf.  

**Storage**  
Container sind ephemer(flüchtig) - Durch Mounten können die Daten gesichert werden.  

​```docker run -v /host/pfad:/container/pfad image_name``` # -v steht fuer Volume/Mount​

**Sandboxing:**

Durch das Zusammenspiel von Namespaces, Cgroups und Netzwerktrennung läuft die Anwendung in einer abgeschotteten Umgebung (der Sandbox). Kritische Softwarefehler oder Sicherheitslücken innerhalb des Containers bleiben dadurch auf diese Laufzeitumgebung beschränkt und gefährden nicht den Host-Betriebssystemkern.




### Praxis-Beispiel
Nach der Installation von Docker:  

**Basics**
1) Von Dockerhub Image namen kopieren
2) ```docker pull [imagename]```
3) ```sudo docker run [imagename]```
4) ```sudo mount```  zeigt den pfad vom docker container
5) darin kann eine shell ausgefuehrt werden -it [interactive, terminal]

**Image erstellen**
1) ```podman build . -t [imagenamen]```  auf basis eines lokalen Dockerfiles
2) ```podman run -p 8081:8880 biti:local``` (leitet den Host-Port 8081 auf den Container-Port 8880 um).
3) ```podman run -v ${pwd}:/usr/share/nginx/html biti:local``` spiegelt den order in den container
4) ```podman push [ziel]``` lädt dein fertiges Image in eine Registry hoch).

### Nachteile
- Container teilen sich den gleichen Kernel, dadurch weniger Abschirmung.
- zusäztliche Schicht notwendig (Tool mit Plattform)  

### Quellenverzeichnis
https://de.wikipedia.org/wiki/Containervirtualisierung  

https://www.youtube.com/watch?v=zJ4ygKEgeIc UMass CS677 (Spring'23) - Lecture 09 - Virtualization, OS Virtualization  

https://www.geeksforgeeks.org/computer-networks/operating-system-based-virtualization/    

https://www.baeldung.com/linux/docker-containers-evolution   

man docker  

---
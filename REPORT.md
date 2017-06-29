# SlideFeedback


## Introduction

Most students know the feeling, you're attending a lecture and the lecturer goes so fast through the materials you get confused. Or the lecturer goes on and on about subjects that were dealt with earlier. Raising your hand interrupts the lecture however so there is no good way to do something about this, yet...

This problem I try to solve by building an application. When the lecturer uses my application to display his slideshows the students will have the possibility to follow the slideshow on their phones/tablets. But most important: they can send their feedback (either too slow or too fast) to the lecturer. The feedback of course will not be displayed in an intrusive manner, but just as a subtle notification, and only when a certain fraction of the students submits the same feedback.

This idea is born during one of my earlier courses, where my team developed an idea for a system that provides adaptive slides during lectures. The feedback was a part of this, but some lecturers showed interest in primarily this part of the system. This drove me to choose the feedback on slides as subject for this project.

Below is a screenshot of the student view:

<img src="doc/screenshot1.png" width="400">

## Technical Design

For all this to work I need a way for real-time bidirectional event-based communication. For this purpose I will use [Socket.IO](https://www.socket.io).
I will further need a server for all clients to connect to, and to process and store the slideshows. For this I will use a VPS from [DigitalOcean](https://www.digitalocean.com), installed with [Ubuntu](https://www.ubuntu.com) and [Python](https://python.org) with libraries [[Flask](http://flask.pocoo.org), [PyPDF2](https://pypi.python.org/pypi/PyPDF2/1.26.0), [Socket.IO](https://pypi.python.org/pypi/python-socketio)].

For authentication and database purposes I will make use of [Firebase](https://firebase.google.com). This database will be used to store information on users and slideshows, as can be seen in the following image:

<img src="doc/firebaseNew.png" alt="Firebase Schema" width="350" />

The necessary real-time communication (next/previous slide, available slides and feedback) will be provided by Socket.IO. On the server, the rooms (presentations) are managed. A client can take control of a room when he/she is a lecturer, and "normal" clients can join a room. When the lecturer emits a changePage event, the matching room is found and the event is retransmitted to everyone in there. When feedback comes in, the lecturer of the room is located and he or she gets the feedback from the server. This works the same way for other events.

When we look at the code for the app itself the MVC-principle is used, although this is almost forced on you by Apple :-). Every screen in the UI has its own UIViewController. Some extensions are used to implement specific functions, such as the spacing and sizing of the UIWebView or displaying alerts in a UIViewcontroller. Firebase and Socket.IO will both get a model/manager in the form of a singleton, to prevent multiple connections etc. These singletons contain all code related to SocketIO and Firebase, this is nice for code maintainability, for instance if you would decide to switch to another library for socket-communication, you will only have to make adjustments in that specific file. Events within the app are handled using the NotificationCenter.

## Process

Alles bij elkaar was de ontwikkeling van deze app een uitdaging, met name door de vele facetten (de app zelf met rol-gebaseerde toegang, een server en een website). Ook het vele real-time eventgebaseerde werk leverde moeilijkheden op. Uiteindelijk ben ik tevreden met het resultaat. Er is zeer weinig afgeweken van het eerste plan in het Design Document, het grootste verschil is dat in de huidige situaties de slides gestart worden vanaf de website. Daar kan men dus slides oploaden en vervolgens starten. De slides openen dan fullscreen op een nieuwe pagina. Vanuit de app worden deze slides dan bediend, de app krijgt een notificatie wanneer er slides vanaf dezelfde user worden gestart en neemt dan de controle over deze slideshow. De reden voor deze verandering is dat het gebruik van het systeem zo beter aansluit op de praktijk. De docent start op de computer in de collegezaal de slides, deze worden dan fullscreen getoond op de projector. Vervolgens kan met de app de bediening worden gedaan, net als een presentatiemuis.

Verder zijn er enkele kleine veranderingen gedaan, zo is er in het Design Document een knopje te zien bij de history waarmee gekozen kan worden om alleen slides met feedback te tonen. Dit is uit het uiteindelijke product gebleven, simpelweg door tijdsgebrek. Ik heb de laatste beschikbare tijd besteed aan het oplossen van bugs, onder het motto "liever een simpel maar goed product, dan een uitgebreid product dat niet goed werkt". Hiernaast zijn de feedback-icons voor de docent vervangen voor het veranderen van de kleur van de menubalk in combinatie met een label. Dit was een idee dat tijdens een van de standups naar voren is gekomen.

Een aantal keuzes die niet in het Design Document zijn behandeld maar wel gemaakt volgen nu. Allereerst is het in de huidige situatie een keer per slide mogelijk om feedback te geven voor studenten. Uiteraard wil je hier een limiet aan stellen en een keer per slide is een logische, makkelijk te handhaven limiet. Verder wordt nu feedback weergegeven bij de docent wanneer 30% van de studenten dit minstens heeft gestemd. Het aantal studenten wordt hierbij bepaald door het aantal verbonden devices. De beide stemmen heffen elkaar tevens op. 

Een aantal mogelijkheden is bewust uit de app gelaten. Denk hierbij aan zaken als profiel aanpassen, wachtwoord/email wijzigen etc. Ook moet nu wanneer iemand docent wil worden dit handmatig in Firebase worden aangepast. Als deze app daadwerkelijk in gebruik genomen zou worden zou je hiervoor een admin-paneel moeten maken. Ook kunnen docenten op dit moment geen slides uit hun collectie weggooien (wel uit hun geschiedenis). Deze functionaliteit zou normaliter in de website geimplementeerd worden maar aangezien de app het voornaamste belang heeft is ervoor gekozen de tijd ergens anders in te investeren. Hiernaast zou dan besloten moeten worden wat er gebeurt met de studenten die de betreffende slides in hun geschiedenis hebben.

Wat betreft het in real-life in gebruik nemen van dit systeem: op dit moment is er een schalingsprobleem. Het systeem weergeeft alle openstaande presentaties bij de studenten. Wanneer dit systeem op een enkele faculteit wordt toegepast zou dit prima kunnen, bij meer raakt men echter snel het overzicht kwijt. Een oplossing hiervoor zou bijvoorbeeld een zoekfunctie zijn, of de mogelijkheid je in te schrijven voor bijvoorbeeld vakken.


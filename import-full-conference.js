const { MongoClient, ServerApiVersion, ObjectId } = require('mongodb');

// Connection credentials with the correct password
const username = "hichem";
const password = "40221326Hi";
const encodedPassword = encodeURIComponent(password);

// Connection string with encoded password
const uri = `mongodb://${username}:${encodedPassword}@cluster0-shard-00-00.pt98b.mongodb.net:27017,cluster0-shard-00-01.pt98b.mongodb.net:27017,cluster0-shard-00-02.pt98b.mongodb.net:27017/?replicaSet=atlas-kh0q9s-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=Cluster0`;

// Create a MongoClient with a MongoClientOptions object
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
  connectTimeoutMS: 30000,
  socketTimeoutMS: 30000
});

async function importFullConferenceData() {
  try {
    // Connect to the MongoDB server
    console.log("Connecting to MongoDB Atlas...");
    await client.connect();
    console.log("Connected successfully to MongoDB Atlas");

    // Use the AfranDB database
    const database = client.db("AfranDB");
    
    // Drop existing collections if they exist (for clean setup)
    try {
      await database.collection("speakers").drop();
      await database.collection("sessions").drop();
      await database.collection("rooms").drop();
      await database.collection("days").drop();
      console.log("Dropped existing collections");
    } catch (e) {
      console.log("Collections did not exist or could not be dropped");
    }

    // Create collections
    console.log("Creating collections...");
    
    // 1. Create speakers collection
    await database.createCollection("speakers");
    console.log("Created speakers collection");

    // 2. Create rooms collection
    await database.createCollection("rooms");
    console.log("Created rooms collection");

    // 3. Create days collection
    await database.createCollection("days");
    console.log("Created days collection");

    // 4. Create sessions collection
    await database.createCollection("sessions");
    console.log("Created sessions collection");

    // Add full conference data
    console.log("Populating collections with full conference data...");

    // Insert rooms
    const roomsCollection = database.collection("rooms");
    const roomsResult = await roomsCollection.insertMany([
      {
        name: "Pr. Hassouna BEN AYED Conference Hall",
        capacity: 500
      },
      {
        name: "Pr. Adel KHEDHER Conference Room",
        capacity: 300
      },
      {
        name: "Pr. Abdelhamid JARRAYA Conference Room",
        capacity: 200
      }
    ]);
    console.log(`${roomsResult.insertedCount} rooms inserted`);
    
    // Get room IDs for references
    const rooms = await roomsCollection.find({}).toArray();
    const roomIds = {};
    rooms.forEach(room => {
      roomIds[room.name] = room._id;
    });

    // Insert days
    const daysCollection = database.collection("days");
    const daysResult = await daysCollection.insertMany([
      {
        date: new Date("2025-04-15"),
        dayNumber: 1,
        dayName: "Tuesday"
      },
      {
        date: new Date("2025-04-16"),
        dayNumber: 2,
        dayName: "Wednesday"
      },
      {
        date: new Date("2025-04-17"),
        dayNumber: 3,
        dayName: "Thursday"
      },
      {
        date: new Date("2025-04-18"),
        dayNumber: 4,
        dayName: "Friday"
      }
    ]);
    console.log(`${daysResult.insertedCount} days inserted`);

    // Get day IDs for references
    const days = await daysCollection.find({}).toArray();
    const dayIds = {};
    days.forEach(day => {
      dayIds[day.dayNumber] = day._id;
    });

    // Insert speakers
    const speakersCollection = database.collection("speakers");
    const speakersResult = await speakersCollection.insertMany([
      {
        name: "Christophe MARIAT",
        country: "FRANCE",
        bio: "Head of the Department of Nephrology Dialysis and Renal Transplantation, Saint-Etienne University Hospital, Jean Monnet University - France",
        image: "mariat_image_url.jpg",
        title: "Professor",
        affiliations: ["Saint-Etienne University Hospital", "Jean Monnet University"]
      },
      {
        name: "Wissal SAHTOUT",
        country: "TUNISIE",
        bio: "Professor of Nephrology, Faculty of Medicine of Sousse, Department of Nephrology, Sahloul University Hospital - Sousse, Tunisia",
        image: "sahtout_image_url.jpg",
        title: "Professor",
        affiliations: ["Faculty of Medicine of Sousse", "Sahloul University Hospital"]
      },
      {
        name: "Faiza ZERDOUMI",
        country: "ALGERIA",
        bio: "Professor of Nephrology, Head of the Department of Nephrology-Hemodialysis, University Hospital, Oran – Algeria",
        image: "zerdoumi_image_url.jpg",
        title: "Professor",
        affiliations: ["University Hospital, Oran"]
      },
      {
        name: "Thierry LOBBEDEZ",
        country: "FRANCE",
        bio: "Professor-Hospital Practitioner, Head of the Department of Nephrology, Caen University Hospital - France",
        image: "lobbedez_image_url.jpg",
        title: "Professor",
        affiliations: ["Caen University Hospital"]
      },
      {
        name: "Marcello TONELLI",
        country: "CANADA",
        bio: "Professor of Medicine, Nephrologist - University of Calgary, Canada, Founding Director of the World Health Organization Collaborating Centre on Prevention and Control of Chronic Kidney Disease",
        image: "tonelli_image_url.jpg",
        title: "Professor",
        affiliations: ["University of Calgary", "WHO Collaborating Centre"]
      },
      {
        name: "Hichem KHELOUFI",
        country: "ALGÉRIE",
        bio: "Assistant Professor of Nephrology, Faculty of Medicine of Setif, Head of the peritoneal dialysis unit, CHU Setif",
        image: "kheloufi_image_url.jpg",
        title: "Assistant Professor",
        affiliations: ["Faculty of Medicine of Setif", "CHU Setif"]
      },
      {
        name: "Hafedh FESSI",
        country: "Tunisia",
        bio: "Consultant Nephrologist, Head of the Renal Therapies Department, Tenon Hospital AP - Paris, France",
        image: "fessi_image_url.jpg",
        title: "Consultant Nephrologist",
        affiliations: ["Tenon Hospital AP"]
      },
      // Add more speakers here...
    ]);
    console.log(`${speakersResult.insertedCount} speakers inserted`);

    // Get speaker IDs for references
    const speakers = await speakersCollection.find({}).toArray();
    const speakerIds = {};
    speakers.forEach(speaker => {
      speakerIds[speaker.name] = speaker._id;
    });

    // Insert sessions
    const sessionsCollection = database.collection("sessions");
    const sessionsResult = await sessionsCollection.insertMany([
      {
        title: "Transplantation Rénale : Donneur Vivant",
        type: "Session",
        day: dayIds[1],
        room: roomIds["Pr. Hassouna BEN AYED Conference Hall"],
        startTime: "09:00",
        endTime: "10:30",
        moderators: ["Mohamed Mongi Bacha", "Tahar Rayane", "Francois Vrtovsnik"],
        interventions: [
          {
            title: "Donneur Vivant, Recommandations de l'Agence de Biomédecine, de la SFT et de La SFNDT",
            speaker: speakerIds["Christophe MARIAT"],
            duration: 30,
            order: 1
          },
          {
            title: "Donneur Vivant Limite : Cas Clinique 1",
            speaker: speakerIds["Wissal SAHTOUT"],
            duration: 30,
            order: 2
          },
          {
            title: "Donneur Vivant Limite : Cas Clinique 2",
            speaker: speakerIds["Faiza ZERDOUMI"],
            duration: 30,
            order: 3
          }
        ]
      },
      {
        title: "Dialyse de qualité en 2025",
        type: "Session",
        day: dayIds[1],
        room: roomIds["Pr. Hassouna BEN AYED Conference Hall"],
        startTime: "11:00",
        endTime: "13:00",
        moderators: ["Abdellatif Achour", "Abdellatif Sidi Ali", "Thierry Lobbedez"],
        interventions: [
          {
            title: "Choix de la Méthode de Dialyse",
            speaker: speakerIds["Thierry LOBBEDEZ"],
            duration: 30,
            order: 1
          },
          {
            title: "L'abord de dialyse",
            speaker: speakerIds["Hichem KHELOUFI"],
            duration: 30,
            order: 2
          },
          {
            title: "Recommandations Pour Une Dialyse de Haute Qualité",
            speaker: speakerIds["Hafedh FESSI"],
            duration: 30,
            order: 3
          },
          {
            title: "Qualité et Sécurité Des Soins en Dialyse, Place des Indicateurs De Performance",
            speaker: speakerIds["Thierry LOBBEDEZ"],
            duration: 30,
            order: 4
          }
        ]
      },
      {
        title: "Néphropathies Glomérulaires, Recommandations KDIGO : Fiches SFNDT",
        type: "Session",
        day: dayIds[1],
        room: roomIds["Pr. Hassouna BEN AYED Conference Hall"],
        startTime: "14:00",
        endTime: "16:00",
        moderators: ["Hedi Ben Maiz", "Hocein Dkhissi", "Christophe Mariat"],
        interventions: [
          {
            title: "Syndrome Néphrotique Idiopathique",
            speaker: speakerIds["Sidi Mohamed Mah"],
            duration: 20,
            order: 1
          },
          {
            title: "Glomérulonéphrite Extra-membraneuse",
            speaker: speakerIds["Mohamed Akli BOUBCHIR"],
            duration: 20,
            order: 2
          },
          {
            title: "Glomérulonéphrite à Dépôts Mésangiaux d'Ig A",
            speaker: speakerIds["Christophe MARIAT"],
            duration: 20,
            order: 3
          },
          {
            title: "Glomérulonéphrite Lupique",
            speaker: speakerIds["Lamia RAIES"],
            duration: 20,
            order: 4
          },
          {
            title: "Vascularites à ANCA",
            speaker: speakerIds["Meriam HAJJI"],
            duration: 20,
            order: 5
          }
        ]
      },
      {
        title: "Les Hyponatrémies",
        type: "Session",
        day: dayIds[1],
        room: roomIds["Pr. Hassouna BEN AYED Conference Hall"],
        startTime: "16:30",
        endTime: "17:30",
        moderators: ["Hayet Kaaroud", "Hubert Yao", "Francois Vrtovsnik"],
        interventions: [
          {
            title: "Les hyponatrémies, Diagnostic et Traitement",
            speaker: speakerIds["Francois VRTOVSNIK"],
            duration: 30,
            order: 1
          },
          {
            title: "Les Hyponatrémies, Cas Clinique 1",
            speaker: speakerIds["Jannet LABIDI"],
            duration: 30,
            order: 2
          },
          {
            title: "Les Hyponatrémies, Cas Clinique 2",
            speaker: speakerIds["Zeinabou Maiga Moussa TONDI"],
            duration: 30,
            order: 3
          }
        ]
      },
      {
        title: "OPENING CEREMONY",
        type: "Ceremony",
        day: dayIds[1],
        room: roomIds["Pr. Hassouna BEN AYED Conference Hall"],
        startTime: "18:30",
        endTime: "19:30",
        moderators: ["Ezzedine Abderrahim", "Habib Skhiri"],
        interventions: [
          {
            title: "Welcome Messages",
            speaker: null, // Multiple speakers
            duration: 20,
            order: 1
          },
          {
            title: "Tunisian Ministry of Health Welcome Address",
            speaker: null,
            duration: 20,
            order: 2
          },
          {
            title: "Keynote Opening Conference: The burden of CKD and other NCDs in Africa: Opportunities and challenges for health systems",
            speaker: speakerIds["Marcello TONELLI"],
            duration: 30,
            order: 3
          }
        ]
      },
      // Add more sessions for other days here...
    ]);
    console.log(`${sessionsResult.insertedCount} sessions inserted`);

    // Create indexes
    console.log("Creating indexes...");
    
    // Speaker indexes
    await speakersCollection.createIndex({ name: 1 });
    await speakersCollection.createIndex({ country: 1 });
    
    // Session indexes
    await sessionsCollection.createIndex({ day: 1 });
    await sessionsCollection.createIndex({ room: 1 });
    await sessionsCollection.createIndex({ type: 1 });
    await sessionsCollection.createIndex({ "interventions.speaker": 1 });
    
    // Day indexes
    await daysCollection.createIndex({ date: 1 });
    
    console.log("Indexes created successfully");

    console.log("\nFull conference data import completed successfully!");
    
  } catch (error) {
    console.error("Error importing full conference data:", error);
  } finally {
    // Close the connection
    await client.close();
    console.log("MongoDB connection closed");
  }
}

// Run the import function
importFullConferenceData().catch(console.dir); 
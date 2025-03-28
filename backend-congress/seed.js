const mongoose = require('mongoose');
const dotenv = require('dotenv');
const { Speaker, Session, Sponsor, Message, Ad, Room } = require('./models');

dotenv.config();

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection failed:', err));

const seedData = async () => {
  try {
    // 🧹 Suppression des anciennes données
    await Speaker.deleteMany();
    await Session.deleteMany();
    await Sponsor.deleteMany();
    await Message.deleteMany();
    await Ad.deleteMany();
    await Room.deleteMany();

    console.log('🧹 Anciennes données supprimées');

    // 🏢 Ajout des salles
    const rooms = await Room.insertMany([
      {
        name: 'Salle A',
        capacity: 200,
        location: '1er étage'
      },
      {
        name: 'Salle B',
        capacity: 150,
        location: '2ème étage'
      },
      {
        name: 'Salle C',
        capacity: 100,
        location: '3ème étage'
      },
      {
        name: 'Amphithéâtre Principal',
        capacity: 500,
        location: 'Rez-de-chaussée'
      }
    ]);

    console.log(`✅ ${rooms.length} salles ajoutées`);

    // 👥 Ajout des intervenants (Speakers)
    const speakers = await Speaker.insertMany([
      {
        name: 'Dr. Jean Dupont',
        country: 'France',
        flagUrl: 'https://flagcdn.com/fr.svg',
        bio: 'Professeur en pharmacologie et expert en développement de médicaments.',
        imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg'
      },
      {
        name: 'Dr. Marie Curie',
        country: 'France',
        flagUrl: 'https://flagcdn.com/fr.svg',
        bio: 'Chercheuse émérite en radiologie et double lauréate du prix Nobel.',
        imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg'
      },
      {
        name: 'Dr. Ahmed Hassan',
        country: 'Égypte',
        flagUrl: 'https://flagcdn.com/eg.svg',
        bio: 'Spécialiste des maladies tropicales et de la médecine préventive.',
        imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg'
      },
      {
        name: 'Dr. Fatima Benali',
        country: 'Maroc',
        flagUrl: 'https://flagcdn.com/ma.svg',
        bio: 'Experte en santé publique et politiques sanitaires en Afrique du Nord.',
        imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg'
      },
      {
        name: 'Prof. James Wilson',
        country: 'États-Unis',
        flagUrl: 'https://flagcdn.com/us.svg',
        bio: 'Pionnier dans la recherche sur les maladies génétiques rares.',
        imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg'
      }
    ]);

    console.log(`✅ ${speakers.length} intervenants ajoutés`);

    // 📅 Ajout des sessions
    const sessions = await Session.insertMany([
      {
        title: 'Session d\'ouverture - AFRAN 2025',
        room: 'Amphithéâtre Principal',
        day: 1,
        startTime: '09:00',
        endTime: '10:30',
        description: 'Session inaugurale du congrès AFRAN 2025 avec présentation des objectifs et des thématiques.',
        speakers: [speakers[0]._id, speakers[3]._id],
        subsessions: [
          {
            title: 'Discours de bienvenue',
            startTime: '09:00',
            endTime: '09:15',
            description: 'Mot d\'accueil et présentation du congrès',
            speakers: [speakers[0]._id],
            subsubsessions: []
          },
          {
            title: 'Présentation des thématiques',
            startTime: '09:15',
            endTime: '09:45',
            description: 'Aperçu des différentes thématiques qui seront abordées pendant le congrès',
            speakers: [speakers[3]._id],
            subsubsessions: []
          },
          {
            title: 'Panel d\'introduction',
            startTime: '09:45',
            endTime: '10:30',
            description: 'Discussion entre experts sur les enjeux actuels',
            speakers: [speakers[0]._id, speakers[1]._id, speakers[3]._id],
            subsubsessions: [
              {
                title: 'Tendances actuelles en recherche',
                startTime: '09:45',
                endTime: '10:00',
                description: 'Présentation des dernières tendances',
                speakers: [speakers[1]._id]
              },
              {
                title: 'Défis en Afrique du Nord',
                startTime: '10:00',
                endTime: '10:15',
                description: 'Analyse des défis spécifiques à la région',
                speakers: [speakers[3]._id]
              },
              {
                title: 'Questions-réponses',
                startTime: '10:15',
                endTime: '10:30',
                description: 'Séance interactive avec l\'audience',
                speakers: [speakers[0]._id, speakers[1]._id, speakers[3]._id]
              }
            ]
          }
        ]
      },
      {
        title: 'Innovations pharmaceutiques',
        room: 'Salle A',
        day: 1,
        startTime: '11:00',
        endTime: '12:30',
        description: 'Présentation des dernières avancées en recherche pharmaceutique.',
        speakers: [speakers[1]._id, speakers[4]._id],
        subsessions: [
          {
            title: 'Nouveaux traitements anticancéreux',
            startTime: '11:00',
            endTime: '11:45',
            description: 'Présentation des molécules prometteuses',
            speakers: [speakers[1]._id],
            subsubsessions: []
          },
          {
            title: 'Thérapies géniques innovantes',
            startTime: '11:45',
            endTime: '12:30',
            description: 'Applications cliniques récentes',
            speakers: [speakers[4]._id],
            subsubsessions: []
          }
        ]
      },
      {
        title: 'Santé publique en Afrique',
        room: 'Salle B',
        day: 1,
        startTime: '14:00',
        endTime: '16:00',
        description: 'État des lieux et perspectives pour les systèmes de santé africains.',
        speakers: [speakers[2]._id, speakers[3]._id],
        subsessions: [
          {
            title: 'Systèmes de surveillance épidémiologique',
            startTime: '14:00',
            endTime: '15:00',
            description: 'Renforcement des capacités locales',
            speakers: [speakers[2]._id],
            subsubsessions: [
              {
                title: 'Étude de cas: Réponse au COVID-19',
                startTime: '14:30',
                endTime: '15:00',
                description: 'Leçons apprises de la pandémie',
                speakers: [speakers[2]._id]
              }
            ]
          },
          {
            title: 'Accès aux médicaments essentiels',
            startTime: '15:00',
            endTime: '16:00',
            description: 'Stratégies pour améliorer la disponibilité',
            speakers: [speakers[3]._id],
            subsubsessions: []
          }
        ]
      },
      {
        title: 'Atelier pratique: Méthodologie de recherche',
        room: 'Salle C',
        day: 2,
        startTime: '09:00',
        endTime: '12:00',
        description: 'Formation pratique aux techniques de recherche avancées.',
        speakers: [speakers[0]._id, speakers[4]._id],
        subsessions: []
      },
      {
        title: 'Coopération internationale',
        room: 'Amphithéâtre Principal',
        day: 2,
        startTime: '14:00',
        endTime: '16:30',
        description: 'Renforcement des partenariats Nord-Sud dans la recherche.',
        speakers: [speakers[0]._id, speakers[2]._id, speakers[4]._id],
        subsessions: []
      },
      {
        title: 'Session de clôture',
        room: 'Amphithéâtre Principal',
        day: 3,
        startTime: '15:00',
        endTime: '17:00',
        description: 'Bilan du congrès et perspectives futures.',
        speakers: [speakers[0]._id, speakers[1]._id, speakers[2]._id, speakers[3]._id, speakers[4]._id],
        subsessions: []
      }
    ]);

    console.log(`✅ ${sessions.length} sessions ajoutées`);

    // 💼 Ajout des sponsors
    const sponsors = await Sponsor.insertMany([
      {
        name: 'PharmaCorp International',
        rank: 'Platinum',
        imageUrl: 'https://example.com/logos/pharmacorp.png'
      },
      {
        name: 'MédiTech Solutions',
        rank: 'Gold',
        imageUrl: 'https://example.com/logos/meditech.png'
      },
      {
        name: 'Laboratoires Africains Unis',
        rank: 'Silver',
        imageUrl: 'https://example.com/logos/lau.png'
      },
      {
        name: 'Fondation Sciences Sans Frontières',
        rank: 'Bronze',
        imageUrl: 'https://example.com/logos/fssf.png'
      }
    ]);

    console.log(`✅ ${sponsors.length} sponsors ajoutés`);

    // 📢 Ajout des messages
    const messages = await Message.insertMany([
      {
        title: 'Message du Président',
        content: 'Chers congressistes, c\'est avec un immense plaisir que nous vous accueillons à cette édition 2025 du congrès AFRAN. Pendant ces trois jours, nous aurons l\'occasion d\'échanger sur les avancées scientifiques les plus récentes et de renforcer nos liens de coopération.'
      },
      {
        title: 'Note du comité scientifique',
        content: 'Le comité scientifique a sélectionné avec soin les interventions pour cette édition. Les thématiques abordées reflètent les défis contemporains auxquels font face nos communautés scientifiques.'
      },
      {
        title: 'Informations pratiques',
        content: 'Les pauses café seront servies dans le hall principal. Le déjeuner est prévu chaque jour de 12h30 à 14h00. Un service de navettes est disponible entre les hôtels partenaires et le lieu du congrès.'
      }
    ]);

    console.log(`✅ ${messages.length} messages ajoutés`);

    // 📣 Ajout des publicités
    const ads = await Ad.insertMany([
      {
        content: 'Découvrez nos solutions innovantes en santé',
        imageUrl: 'https://example.com/ads/ad1.png',
        linkUrl: 'https://pharmacorp-international.com/innovations'
      },
      {
        content: 'Recrutement en cours: rejoignez notre équipe de recherche',
        imageUrl: 'https://example.com/ads/ad2.png',
        linkUrl: 'https://meditech-solutions.fr/carrieres'
      },
      {
        content: 'Programme de bourses 2026 - Candidatez dès maintenant',
        imageUrl: 'https://example.com/ads/ad3.png',
        linkUrl: 'https://sciences-sans-frontieres.org/bourses'
      }
    ]);

    console.log(`✅ ${ads.length} publicités ajoutées`);

    console.log('✅ Toutes les données ont été insérées avec succès');
    process.exit();
  } catch (err) {
    console.error('❌ Erreur lors de l\'insertion des données:', err);
    process.exit(1);
  }
};

seedData();
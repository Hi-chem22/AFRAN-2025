// Mock data for testing the UI

// Sessions data
final List<Map<String, dynamic>> mockSessions = [
  {
    'id': 's1',
    'title': 'Ouverture du Congrès AFRAN 2025',
    'description': 'Session d\'ouverture officielle du congrès AFRAN 2025 avec les discours des représentants officiels.',
    'startTime': '09:00',
    'endTime': '10:30',
    'room': 'Grand Auditorium',
    'speakerIds': ['sp1', 'sp2'],
    'day': 1,
    'isFeatured': true,
    'interventions': [
      {
        'title': 'Allocution de bienvenue',
        'speakerId': 'sp1',
        'duration': '15 min'
      },
      {
        'title': 'Perspectives pour l\'AFRAN 2025',
        'speakerId': 'sp2',
        'duration': '20 min'
      }
    ]
  },
  {
    'id': 's2',
    'title': 'Les progrès de la médecine africaine',
    'description': 'Une présentation des avancées récentes dans le domaine de la médecine en Afrique.',
    'startTime': '11:00',
    'endTime': '12:30',
    'room': 'Salle A',
    'speakerIds': ['sp3'],
    'day': 1,
    'isFeatured': true,
    'interventions': [
      {
        'title': 'Lutte contre les maladies infectieuses en Afrique',
        'speakerId': 'sp3',
        'duration': '45 min'
      }
    ]
  },
  {
    'id': 's3',
    'title': 'Technologies de l\'information en Afrique',
    'description': 'Comment les nouvelles technologies transforment le continent africain.',
    'startTime': '14:00',
    'endTime': '15:30',
    'room': 'Salle B',
    'speakerIds': ['sp4', 'sp5'],
    'day': 1,
    'isFeatured': false,
    'interventions': [
      {
        'title': 'L\'essor des startups tech en Afrique de l\'Ouest',
        'speakerId': 'sp4',
        'duration': '25 min'
      },
      {
        'title': 'Applications des SIG pour le développement rural',
        'speakerId': 'sp5',
        'duration': '25 min'
      }
    ]
  },
  {
    'id': 's4',
    'title': 'Énergie renouvelable et développement durable',
    'description': 'Exploration des solutions d\'énergie renouvelable adaptées au contexte africain.',
    'startTime': '16:00',
    'endTime': '17:30',
    'room': 'Salle C',
    'speakerIds': ['sp6'],
    'day': 1,
    'isFeatured': false,
    'interventions': [
      {
        'title': 'Solutions solaires pour les zones rurales africaines',
        'speakerId': 'sp6',
        'duration': '40 min'
      }
    ]
  },
  {
    'id': 's5',
    'title': 'Réception de Bienvenue',
    'description': 'Cocktail de bienvenue et réseautage pour tous les participants.',
    'startTime': '18:30',
    'endTime': '20:00',
    'room': 'Hall Principal',
    'speakerIds': [],
    'day': 1,
    'isFeatured': true,
    'interventions': []
  },
  {
    'id': 's6',
    'title': 'Dialyse de qualité en 2025',
    'description': 'Nouvelles approches et techniques pour améliorer la qualité de la dialyse.',
    'startTime': '11:00',
    'endTime': '13:00',
    'room': 'Pr. Hassouna BEN AYED Conference Hall',
    'speakerIds': ['sp7', 'sp8', 'sp9'],
    'day': 2,
    'isFeatured': true,
    'interventions': [
      {
        'title': 'Avancées technologiques en dialyse',
        'speakerId': 'sp7',
        'duration': '30 min'
      },
      {
        'title': 'Approches intégrées pour la dialyse en Algérie',
        'speakerId': 'sp8',
        'duration': '30 min'
      },
      {
        'title': 'Standards de qualité pour la dialyse en Afrique',
        'speakerId': 'sp9',
        'duration': '30 min'
      }
    ]
  },
  {
    'id': 's7',
    'title': 'Santé maternelle et infantile',
    'description': 'Stratégies pour améliorer la santé maternelle et infantile dans différents contextes africains.',
    'startTime': '09:00',
    'endTime': '11:00',
    'room': 'Salle A',
    'speakerIds': ['sp10', 'sp11'],
    'day': 2,
    'isFeatured': false,
    'interventions': [
      {
        'title': 'Réduction de la mortalité maternelle',
        'speakerId': 'sp10',
        'duration': '35 min'
      },
      {
        'title': 'Vaccination et santé infantile',
        'speakerId': 'sp11',
        'duration': '35 min'
      }
    ]
  },
  {
    'id': 's8',
    'title': 'Maladies tropicales négligées',
    'description': 'État des lieux et nouvelles approches thérapeutiques pour les maladies tropicales négligées.',
    'startTime': '14:00',
    'endTime': '16:00',
    'room': 'Salle B',
    'speakerIds': ['sp3', 'sp12'],
    'day': 2,
    'isFeatured': false,
    'interventions': [
      {
        'title': 'Épidémiologie des maladies tropicales négligées',
        'speakerId': 'sp3',
        'duration': '40 min'
      },
      {
        'title': 'Nouvelles approches thérapeutiques',
        'speakerId': 'sp12',
        'duration': '40 min'
      }
    ]
  },
  {
    'id': 's9',
    'title': 'Dîner de Gala',
    'description': 'Soirée festive avec remise de prix aux contributeurs exceptionnels de l\'AFRAN.',
    'startTime': '19:00',
    'endTime': '23:00',
    'room': 'Grand Hall',
    'speakerIds': ['sp1'],
    'day': 2,
    'isFeatured': true,
    'interventions': [
      {
        'title': 'Discours et remise de prix',
        'speakerId': 'sp1',
        'duration': '30 min'
      }
    ]
  },
  {
    'id': 's10',
    'title': 'Clôture du Congrès',
    'description': 'Session de clôture avec résumé des points clés du congrès et perspectives futures.',
    'startTime': '16:00',
    'endTime': '17:30',
    'room': 'Grand Auditorium',
    'speakerIds': ['sp1', 'sp2'],
    'day': 3,
    'isFeatured': true,
    'interventions': [
      {
        'title': 'Synthèse du congrès',
        'speakerId': 'sp2',
        'duration': '25 min'
      },
      {
        'title': 'Perspectives pour l\'avenir',
        'speakerId': 'sp1',
        'duration': '25 min'
      }
    ]
  }
];

// Speakers data
final List<Map<String, dynamic>> mockSpeakers = [
  {
    'id': 'sp1',
    'name': 'Dr. Aminata Diallo',
    'bio': 'Présidente de l\'AFRAN et professeure de médecine à l\'Université de Dakar. Spécialiste en néphrologie avec plus de 20 ans d\'expérience dans le domaine médical en Afrique de l\'Ouest.',
    'photoUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
    'company': 'AFRAN',
    'position': 'Présidente',
    'country': 'Sénégal'
  },
  {
    'id': 'sp2',
    'name': 'Prof. Jean-Pierre Nkolo',
    'bio': 'Secrétaire général de l\'AFRAN et directeur de recherche en sciences politiques. Expert en politiques de santé publique et gouvernance des systèmes de santé en Afrique centrale.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
    'company': 'Université de Yaoundé',
    'position': 'Directeur de Recherche',
    'country': 'Cameroun'
  },
  {
    'id': 'sp3',
    'name': 'Dr. Fatima Bensouda',
    'bio': 'Spécialiste en épidémiologie avec 15 ans d\'expérience dans la lutte contre les maladies infectieuses. Elle a dirigé plusieurs campagnes de vaccination et d\'éducation sanitaire au Maroc et dans d\'autres pays d\'Afrique du Nord.',
    'photoUrl': 'https://randomuser.me/api/portraits/women/3.jpg',
    'company': 'Institut Pasteur',
    'position': 'Chercheuse Senior',
    'country': 'Maroc'
  },
  {
    'id': 'sp4',
    'name': 'Kwame Osei',
    'bio': 'Entrepreneur tech et fondateur de plusieurs startups en Afrique de l\'Ouest. Pionnier dans le développement de solutions mobiles pour la santé (mHealth) adaptées aux contextes africains.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/4.jpg',
    'company': 'TechAfrica',
    'position': 'CEO',
    'country': 'Ghana'
  },
  {
    'id': 'sp5',
    'name': 'Dr. Nala Mbeki',
    'bio': 'Experte en systèmes d\'information géographique appliqués au développement rural. Ses travaux ont permis d\'améliorer l\'accès aux soins de santé dans les zones reculées d\'Afrique du Sud.',
    'photoUrl': 'https://randomuser.me/api/portraits/women/5.jpg',
    'company': 'Université du Cap',
    'position': 'Maître de Conférences',
    'country': 'Afrique du Sud'
  },
  {
    'id': 'sp6',
    'name': 'Prof. Ibrahim Kante',
    'bio': 'Spécialiste en énergie solaire avec plusieurs brevets à son actif. Il a développé des solutions innovantes pour alimenter des cliniques et centres de santé en zones rurales non connectées au réseau électrique.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/6.jpg',
    'company': 'Centre de Recherche en Énergies Renouvelables',
    'position': 'Directeur',
    'country': 'Mali'
  },
  {
    'id': 'sp7',
    'name': 'Thierry LOBBEDEZ',
    'bio': 'Expert international en néphrologie et techniques de dialyse. Il a contribué à l\'amélioration des protocoles de dialyse dans plusieurs pays francophones.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/7.jpg',
    'company': 'Hôpital Universitaire',
    'position': 'Chef du Service de Néphrologie',
    'country': 'France'
  },
  {
    'id': 'sp8',
    'name': 'Hichem KHELOUFI',
    'bio': 'Spécialiste en néphrologie avec une expertise particulière dans les approches intégrées pour la dialyse. Il a développé des programmes de formation pour les professionnels de santé en Algérie.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/8.jpg',
    'company': 'Centre Hospitalier Universitaire',
    'position': 'Néphrologue',
    'country': 'Algérie'
  },
  {
    'id': 'sp9',
    'name': 'Hafedh FESSI',
    'bio': 'Expert en qualité des soins et standards internationaux pour la dialyse. Il a contribué à l\'élaboration de directives pour l\'amélioration de la qualité des services de dialyse en Afrique.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/9.jpg',
    'company': 'Faculté de Médecine',
    'position': 'Professeur',
    'country': 'Tunisie'
  },
  {
    'id': 'sp10',
    'name': 'Dr. Aisha Nyongo',
    'bio': 'Spécialiste en santé maternelle avec une vaste expérience dans les programmes de réduction de la mortalité maternelle en Afrique de l\'Est.',
    'photoUrl': 'https://randomuser.me/api/portraits/women/10.jpg',
    'company': 'Organisation Mondiale de la Santé',
    'position': 'Consultante',
    'country': 'Kenya'
  },
  {
    'id': 'sp11',
    'name': 'Dr. Mohammed El-Fasi',
    'bio': 'Pédiatre spécialisé dans les programmes de vaccination et de santé infantile. Il a dirigé plusieurs campagnes de vaccination réussies en Égypte et au Soudan.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/11.jpg',
    'company': 'UNICEF',
    'position': 'Conseiller en Santé Infantile',
    'country': 'Égypte'
  },
  {
    'id': 'sp12',
    'name': 'Prof. Amara Konaté',
    'bio': 'Chercheur en maladies tropicales avec des contributions significatives dans le développement de nouveaux traitements contre la schistosomiase et d\'autres maladies tropicales négligées.',
    'photoUrl': 'https://randomuser.me/api/portraits/men/12.jpg',
    'company': 'Institut de Recherche en Santé Publique',
    'position': 'Directeur de Recherche',
    'country': 'Guinée'
  }
];

// Sponsors data
final List<Map<String, dynamic>> mockSponsors = [
  {
    'id': 'spon1',
    'name': 'AfricaDev Foundation',
    'description': 'Fondation dédiée au développement durable en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/gold/white?text=AfricaDev',
    'website': 'https://example.com/africadev',
    'tier': 'platinum'
  },
  {
    'id': 'spon2',
    'name': 'TechHub Africa',
    'description': 'Accélérateur de startups tech en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/gold/black?text=TechHub',
    'website': 'https://example.com/techhub',
    'tier': 'gold'
  },
  {
    'id': 'spon3',
    'name': 'AfriHealth',
    'description': 'Réseau de cliniques et centres médicaux en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/gold/black?text=AfriHealth',
    'website': 'https://example.com/afrihealth',
    'tier': 'gold'
  },
  {
    'id': 'spon4',
    'name': 'SolarAfrica',
    'description': 'Solutions d\'énergie solaire pour l\'Afrique rurale.',
    'logoUrl': 'https://placehold.co/400x200/silver/black?text=SolarAfrica',
    'website': 'https://example.com/solarafrica',
    'tier': 'silver'
  },
  {
    'id': 'spon5',
    'name': 'EduConnect',
    'description': 'Plateforme d\'éducation en ligne pour les étudiants africains.',
    'logoUrl': 'https://placehold.co/400x200/silver/black?text=EduConnect',
    'website': 'https://example.com/educonnect',
    'tier': 'silver'
  },
  {
    'id': 'spon6',
    'name': 'AfriMobile',
    'description': 'Opérateur télécom pan-africain.',
    'logoUrl': 'https://placehold.co/400x200/cd7f32/white?text=AfriMobile',
    'website': 'https://example.com/afrimobile',
    'tier': 'bronze'
  },
  {
    'id': 'spon7',
    'name': 'MediTech Africa',
    'description': 'Fournisseur d\'équipements médicaux de pointe.',
    'logoUrl': 'https://placehold.co/400x200/cd7f32/white?text=MediTech',
    'website': 'https://example.com/meditech',
    'tier': 'bronze'
  }
];

// Partners data
final List<Map<String, dynamic>> mockPartners = [
  {
    'id': 'part1',
    'name': 'Association Africaine de Néphrologie',
    'description': 'Société savante regroupant les néphrologues africains.',
    'logoUrl': 'https://placehold.co/400x200/navy/white?text=AAN',
    'website': 'https://example.com/aan'
  },
  {
    'id': 'part2',
    'name': 'Société Africaine de Cardiologie',
    'description': 'Organisation médicale dédiée à l\'amélioration des soins cardiovasculaires en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/darkred/white?text=SAC',
    'website': 'https://example.com/sac'
  },
  {
    'id': 'part3',
    'name': 'Fédération Africaine de Gynécologie et d\'Obstétrique',
    'description': 'Fédération regroupant les spécialistes en gynécologie et obstétrique en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/purple/white?text=FAGO',
    'website': 'https://example.com/fago'
  },
  {
    'id': 'part4',
    'name': 'Association des Pédiatres d\'Afrique',
    'description': 'Réseau de pédiatres dédiés à l\'amélioration de la santé infantile sur le continent africain.',
    'logoUrl': 'https://placehold.co/400x200/green/white?text=APA',
    'website': 'https://example.com/apa'
  },
  {
    'id': 'part5',
    'name': 'Société Africaine de Santé Publique',
    'description': 'Organisation professionnelle pour les spécialistes de la santé publique en Afrique.',
    'logoUrl': 'https://placehold.co/400x200/teal/white?text=SASP',
    'website': 'https://example.com/sasp'
  }
];

// Welcome message for home screen
final Map<String, String> welcomeMessage = {
  'title': 'Bienvenue au Congrès AFRAN 2025',
  'message': 'Chers participants, nous sommes ravis de vous accueillir à ce congrès qui réunit les meilleurs experts du continent africain dans le domaine médical. Pendant ces trois jours, nous explorerons ensemble les avancées et innovations qui façonnent l\'avenir de la médecine en Afrique. Profitez des sessions, des opportunités de réseautage et des échanges enrichissants qui vous attendent.'
}; 
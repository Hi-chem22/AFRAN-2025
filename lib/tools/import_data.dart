import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/mongodb_service.dart';
import '../providers/data_source_provider.dart';

class ImportDataTool extends StatefulWidget {
  @override
  _ImportDataToolState createState() => _ImportDataToolState();
}

class _ImportDataToolState extends State<ImportDataTool> {
  MongoDBService? _mongoDBService;
  bool _isLoading = false;
  String _message = '';
  Map<String, int> _stats = {
    'sessions': 0,
    'speakers': 0,
    'sponsors': 0,
    'partners': 0,
  };
  bool _isDatabasePopulated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initService();
    });
  }

  void _initService() async {
    final dataSourceProvider = Provider.of<DataSourceProvider>(context, listen: false);
    _mongoDBService = MongoDBService(mongoUrl: dataSourceProvider.mongodbUrl);
    
    setState(() {
      _isLoading = true;
      _message = 'Vérification de la base de données...';
    });
    
    try {
      final isConnected = await _mongoDBService!.testConnection();
      if (!isConnected) {
        setState(() {
          _isLoading = false;
          _message = 'Impossible de se connecter à MongoDB. Vérifiez votre configuration.';
        });
        return;
      }
      
      final isPopulated = await _mongoDBService!.isDatabasePopulated();
      final stats = await _mongoDBService!.getCollectionStats();
      
      setState(() {
        _isDatabasePopulated = isPopulated;
        _stats = stats;
        _isLoading = false;
        _message = isPopulated 
            ? 'Base de données déjà initialisée. Utilisez le bouton pour réimporter les données.'
            : 'Base de données vide. Prête pour l\'importation.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Erreur: $e';
      });
    }
  }

  Future<void> _importData() async {
    if (_mongoDBService == null) return;
    
    setState(() {
      _isLoading = true;
      _message = 'Importation des données en cours...';
    });

    try {
      await _mongoDBService!.importMockData();
      final stats = await _mongoDBService!.getCollectionStats();
      
      setState(() {
        _stats = stats;
        _isDatabasePopulated = true;
        _isLoading = false;
        _message = 'Données importées avec succès dans MongoDB!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importation des données'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques de la base de données',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildStatsTable(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (_isLoading)
              Center(child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(_message),
                ],
              ))
            else
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _importData,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(_isDatabasePopulated 
                          ? 'Réimporter les données fictives' 
                          : 'Importer les données fictives vers MongoDB'),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _message.contains('succès') ? FontWeight.bold : FontWeight.normal,
                          color: _message.contains('Erreur') ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            _buildTableHeader('Collection'),
            _buildTableHeader('Nombre d\'éléments'),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Sessions'),
            _buildTableCell(_stats['sessions'].toString()),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Intervenants'),
            _buildTableCell(_stats['speakers'].toString()),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Sponsors'),
            _buildTableCell(_stats['sponsors'].toString()),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell('Partenaires'),
            _buildTableCell(_stats['partners'].toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _mongoDBService?.close();
    super.dispose();
  }
} 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Getter seguro que verifica autenticação
  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _uid;
    if (uid == null) {
      throw Exception(
        'Usuário não autenticado. Faça login para salvar cálculos.',
      );
    }
    return _db.collection('users').doc(uid).collection('calculations');
  }

  Future<String> saveCalculation(Map<String, dynamic> data) async {
    try {
      // Verifica autenticação
      if (_uid == null) {
        throw Exception('Usuário não autenticado');
      }

      // Remove valores null (Firestore não aceita null)
      final cleanData = Map<String, dynamic>.from(data);
      cleanData.removeWhere((key, value) => value == null);

      // Converte tipos problemáticos
      final safeData = <String, dynamic>{};
      cleanData.forEach((key, value) {
        if (value is num) {
          // Garante que números sejam double ou int
          safeData[key] = value is int ? value : value.toDouble();
        } else if (value is DateTime) {
          // Converte DateTime para Timestamp do Firestore
          safeData[key] = Timestamp.fromDate(value);
        } else {
          safeData[key] = value;
        }
      });

      // Adiciona timestamp do servidor
      safeData['createdAt'] = FieldValue.serverTimestamp();
      safeData['updatedAt'] = FieldValue.serverTimestamp();

      // Salva no Firestore
      final doc = await _collection.add(safeData);

      print('✅ Cálculo salvo com sucesso! ID: ${doc.id}');
      return doc.id;
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar no Firestore: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchCalculations() {
    try {
      if (_uid == null) {
        return Stream.value([]);
      }

      return _collection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
            return snap.docs.map((doc) {
              final data = doc.data();

              // Converte Timestamp para DateTime para facilitar uso no app
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
              }
              if (data['updatedAt'] is Timestamp) {
                data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
              }

              return {'firestoreId': doc.id, ...data};
            }).toList();
          })
          .handleError((error) {
            print('❌ Erro ao observar cálculos: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('❌ Erro ao configurar stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> deleteCalculation(String firestoreId) async {
    try {
      if (_uid == null) {
        throw Exception('Usuário não autenticado');
      }

      await _collection.doc(firestoreId).delete();
      print('✅ Cálculo deletado com sucesso!');
    } catch (e) {
      print('❌ Erro ao deletar cálculo: $e');
      rethrow;
    }
  }

  // Método adicional para atualizar um cálculo existente
  Future<void> updateCalculation(
    String firestoreId,
    Map<String, dynamic> data,
  ) async {
    try {
      if (_uid == null) {
        throw Exception('Usuário não autenticado');
      }

      // Remove valores null
      final cleanData = Map<String, dynamic>.from(data);
      cleanData.removeWhere((key, value) => value == null);

      // Adiciona timestamp de atualização
      cleanData['updatedAt'] = FieldValue.serverTimestamp();

      await _collection.doc(firestoreId).update(cleanData);
      print('✅ Cálculo atualizado com sucesso!');
    } catch (e) {
      print('❌ Erro ao atualizar cálculo: $e');
      rethrow;
    }
  }

  // Método para verificar se o usuário está autenticado
  bool get isUserAuthenticated => _uid != null;

  // Método para obter o ID do usuário atual
  String? get currentUserId => _uid;

  // Método para limpar todos os cálculos do usuário (uso com cautela)
  Future<void> deleteAllCalculations() async {
    try {
      if (_uid == null) {
        throw Exception('Usuário não autenticado');
      }

      final snapshot = await _collection.get();

      // Deleta em lotes para melhor performance
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ Todos os cálculos foram deletados!');
    } catch (e) {
      print('❌ Erro ao deletar todos os cálculos: $e');
      rethrow;
    }
  }

  // Método para buscar um cálculo específico
  Future<Map<String, dynamic>?> getCalculation(String firestoreId) async {
    try {
      if (_uid == null) {
        throw Exception('Usuário não autenticado');
      }

      final doc = await _collection.doc(firestoreId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Converte Timestamp para DateTime
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
      }

      return {'firestoreId': doc.id, ...data};
    } catch (e) {
      print('❌ Erro ao buscar cálculo: $e');
      rethrow;
    }
  }
}

// Instância global do repositório
final historyRepository = HistoryRepository();

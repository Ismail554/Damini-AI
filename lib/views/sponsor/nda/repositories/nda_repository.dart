import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nda_model.dart';

final ndaRepositoryProvider = Provider<NdaRepository>((ref) {
  return NdaRepository();
});

class NdaRepository {
  Future<NdaAgreementModel> fetchNdaAgreement([String disclosingParty = "Acme Corp"]) async {
    return NdaAgreementModel.mockData(disclosingParty);
  }

  Future<bool> submitSignature({
    required String ndaId,
    required String signatureText,
    String? signatureImagePath,
  }) async {
    return true;
  }
}

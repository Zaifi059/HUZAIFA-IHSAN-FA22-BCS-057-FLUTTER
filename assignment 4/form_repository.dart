import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/form_data.dart';

class FormRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'form_submissions';

  Future<String> create(FormData formData) async {
    final response = await _supabase
        .from(tableName)
        .insert(formData.toJson())
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<List<FormData>> readAll() async {
    final response = await _supabase
        .from(tableName)
        .select('*')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => FormData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FormData> read(String id) async {
    final response = await _supabase
        .from(tableName)
        .select('*')
        .eq('id', id)
        .single();

    return FormData.fromJson(response as Map<String, dynamic>);
  }

  Future<void> update(FormData formData) async {
    await _supabase
        .from(tableName)
        .update(formData.toJson())
        .eq('id', formData.id!);
  }

  Future<void> delete(String id) async {
    await _supabase
        .from(tableName)
        .delete()
        .eq('id', id);
  }
}
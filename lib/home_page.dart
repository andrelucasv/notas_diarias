import 'package:flutter/material.dart';
import 'package:notas_diarias/helper/anotacao_helper.dart';
import 'package:notas_diarias/model/anotacao.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final _db = AnotacaoHelper();
  List<Anotacao>? _anotacoes = [];

  _exibirTelaCadastro() {

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título"
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição"
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancelar")
            ),
            TextButton(
              onPressed: () {

                _salvarAnotacao();

                Navigator.pop(context);
              }, 
              child: const Text("Salvar")
            )
          ],
        );
      }
    );

  }

  _recuperarAnotacoes() async {

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    
    List<Anotacao>? listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);

    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = null;

    //debugPrint("Lista de anotações: ${anotacoesRecuperadas.toString()}");

  }

  _salvarAnotacao() async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    //debugPrint("Data atual: ${DateTime.now().toString()}");
    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int? resultado = await _db.salvarAnotacao(anotacao);
    debugPrint("Anotações salvas: ${resultado.toString()}");

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();

  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas anotações"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                
                final anotacao = _anotacoes?[index];

                return Card(
                  child: ListTile(
                    title: Text("${anotacao?.titulo}"),
                    subtitle: Text("${anotacao?.data} - ${anotacao?.descricao}"),
                  ),
                );

              },
              itemCount: _anotacoes?.length,
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exibirTelaCadastro();
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorInput {
  final double salary;
  final String tipoAviso;
  final String feriasVencidas;
  final int dependentes;
  final DateTime dataAdmissao;
  final DateTime dataDemissao;
  final String insalubridade;
  final int horasExtras;
  final String tipoDesligamento;

  const CalculatorInput({
    required this.salary,
    required this.tipoAviso,
    required this.feriasVencidas,
    required this.dependentes,
    required this.dataAdmissao,
    required this.dataDemissao,
    required this.insalubridade,
    required this.horasExtras,
    required this.tipoDesligamento,
  });
}

class CalculatorResult {
  final double saldoSalario;
  final double avisoPrevio;
  final double decimoTerceiroProporcional;
  final double feriasProporcional;
  final double tercoFerias;
  final double feriasVencidas;
  final double multaFgts;
  final double fgtsDeposito;
  final double insalubridade;
  final double horasExtrasValor;
  final double inss;
  final double totalBruto;
  final double totalDescontos;
  final double totalLiquido;
  final int mesesTrabalhados;

  const CalculatorResult({
    required this.saldoSalario,
    required this.avisoPrevio,
    required this.decimoTerceiroProporcional,
    required this.feriasProporcional,
    required this.tercoFerias,
    required this.feriasVencidas,
    required this.multaFgts,
    required this.fgtsDeposito,
    required this.insalubridade,
    required this.horasExtrasValor,
    required this.inss,
    required this.totalBruto,
    required this.totalDescontos,
    required this.totalLiquido,
    required this.mesesTrabalhados,
  });
}

class CalculatorState {
  final bool isLoading;
  final CalculatorResult? result;
  final CalculatorInput? lastInput;
  final String? errorMessage;

  const CalculatorState({
    this.isLoading = false,
    this.result,
    this.lastInput,
    this.errorMessage,
  });

  CalculatorState copyWith({
    bool? isLoading,
    CalculatorResult? result,
    CalculatorInput? lastInput,
    String? errorMessage,
  }) {
    return CalculatorState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      lastInput: lastInput ?? this.lastInput,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CalculatorViewModel extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  Future<CalculatorResult> calculate(CalculatorInput input) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulação de chamada ao backend (trocar por HTTP quando backend estiver pronto)
      await Future.delayed(const Duration(milliseconds: 300));

      final result = _processCalculation(input);

      state = state.copyWith(
        isLoading: false,
        result: result,
        lastInput: input,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao processar cálculo.',
      );
      rethrow;
    }
  }

  CalculatorResult _processCalculation(CalculatorInput i) {
    final meses = ((i.dataDemissao.difference(i.dataAdmissao).inDays) / 30)
        .floor();

    final saldoSalario = (i.salary / 30) * i.dataDemissao.day;

    final avisoPrevio = i.tipoAviso == 'Indenizado' ? i.salary : 0.0;

    final decimoTerceiro = (i.salary / 12) * meses;

    final feriasProp = (i.salary / 12) * meses;
    final tercoFerias = feriasProp / 3;

    final feriasVenc = () {
      if (i.feriasVencidas == '30 dias') return i.salary + (i.salary / 3);
      if (i.feriasVencidas == '15 dias') return (i.salary / 2) + (i.salary / 6);
      return 0.0;
    }();

    final multa =
        (i.tipoDesligamento == 'Sem justa causa' ||
            i.tipoDesligamento == 'Acordo mútuo')
        ? i.salary * meses * 0.08 * 0.4
        : 0.0;

    final fgts = i.salary * meses * 0.08;

    const salarioMinimo = 1412.0;
    final insalub = () {
      if (i.insalubridade == 'Sim, 10%') return salarioMinimo * 0.10;
      if (i.insalubridade == 'Sim, 20%') return salarioMinimo * 0.20;
      if (i.insalubridade == 'Sim, 40%') return salarioMinimo * 0.40;
      return 0.0;
    }();

    final horasExtrasValor = (i.salary / 220) * 1.5 * i.horasExtras;

    final inss = () {
      if (i.salary <= 1412.00) return i.salary * 0.075;
      if (i.salary <= 2666.68) return i.salary * 0.09;
      if (i.salary <= 4000.03) return i.salary * 0.12;
      return i.salary * 0.14;
    }();

    final totalBruto =
        saldoSalario +
        avisoPrevio +
        decimoTerceiro +
        feriasProp +
        tercoFerias +
        feriasVenc +
        multa +
        horasExtrasValor +
        insalub;

    return CalculatorResult(
      saldoSalario: saldoSalario,
      avisoPrevio: avisoPrevio,
      decimoTerceiroProporcional: decimoTerceiro,
      feriasProporcional: feriasProp,
      tercoFerias: tercoFerias,
      feriasVencidas: feriasVenc,
      multaFgts: multa,
      fgtsDeposito: fgts,
      insalubridade: insalub,
      horasExtrasValor: horasExtrasValor,
      inss: inss,
      totalBruto: totalBruto,
      totalDescontos: inss,
      totalLiquido: totalBruto - inss,
      mesesTrabalhados: meses,
    );
  }

  void clear() {
    state = const CalculatorState();
  }
}

final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(
      CalculatorViewModel.new,
    );

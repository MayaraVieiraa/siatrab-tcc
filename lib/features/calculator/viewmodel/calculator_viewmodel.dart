import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Modelos permanecem iguais
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

  CalculatorInput({
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
  final double inss;
  final double irrf;
  final double totalBruto;
  final double totalDescontos;
  final double totalLiquido;
  final int mesesTrabalhados;
  final double insalubridade;
  final double horasExtrasValor;

  CalculatorResult({
    required this.saldoSalario,
    required this.avisoPrevio,
    required this.decimoTerceiroProporcional,
    required this.feriasProporcional,
    required this.tercoFerias,
    required this.feriasVencidas,
    required this.multaFgts,
    required this.fgtsDeposito,
    required this.inss,
    required this.irrf,
    required this.totalBruto,
    required this.totalDescontos,
    required this.totalLiquido,
    required this.mesesTrabalhados,
    required this.insalubridade,
    required this.horasExtrasValor,
  });
}

class CalculatorState {
  final bool isLoading;
  final CalculatorResult? result;
  final String? error;

  CalculatorState({this.isLoading = false, this.result, this.error});

  CalculatorState copyWith({
    bool? isLoading,
    CalculatorResult? result,
    String? error,
  }) {
    return CalculatorState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

// 2. NOVA LÓGICA (Sintaxe Riverpod 3.x)
class CalculatorViewModel extends Notifier<CalculatorState> {
  @override
  CalculatorState build() {
    return CalculatorState(); // Estado inicial
  }

  void clear() {
    state = CalculatorState();
  }

  Future<void> calculate(CalculatorInput input) async {
    state = state.copyWith(isLoading: true);

    try {
      const double salarioMinimo = 1621.00;
      final diasNoMesDemissao = input.dataDemissao.day;

      int mesesTrabalhadosTotal = _calculateMonths(
        input.dataAdmissao,
        input.dataDemissao,
      );
      final saldoSalario = (input.salary / 30) * diasNoMesDemissao;

      double valorInsalubridade = 0;
      if (input.insalubridade.contains('10%'))
        valorInsalubridade = salarioMinimo * 0.10;
      if (input.insalubridade.contains('20%'))
        valorInsalubridade = salarioMinimo * 0.20;
      if (input.insalubridade.contains('40%'))
        valorInsalubridade = salarioMinimo * 0.40;

      final valorHoraNormal = (input.salary + valorInsalubridade) / 220;
      final valorHoraExtra = valorHoraNormal * 1.5;
      final horasExtrasValor = input.horasExtras * valorHoraExtra;

      final baseCalculo = input.salary + valorInsalubridade;

      final anosCompletos = (mesesTrabalhadosTotal / 12).floor();
      final diasAviso = 30 + (anosCompletos * 3);
      double avisoPrevioValor = (baseCalculo / 30) * diasAviso;

      if (input.tipoDesligamento == 'Acordo mútuo') {
        avisoPrevioValor *= 0.5;
      } else if (input.tipoDesligamento == 'Pedido de demissão' ||
          input.tipoDesligamento == 'Com justa causa') {
        avisoPrevioValor = 0;
      }

      final mesesParaVerbas = input.tipoAviso == 'Indenizado'
          ? mesesTrabalhadosTotal + 1
          : mesesTrabalhadosTotal;
      final meses13 = mesesParaVerbas % 12 == 0 && mesesParaVerbas > 0
          ? 12
          : mesesParaVerbas % 12;
      final decimoTerceiro = (baseCalculo / 12) * meses13;

      final mesesFerias = mesesParaVerbas % 12;
      final feriasProporcional = (baseCalculo / 12) * mesesFerias;

      final diasFeriasVencidas =
          double.tryParse(
            input.feriasVencidas.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
      final feriasVencidasValor = (baseCalculo / 30) * diasFeriasVencidas;

      final totalFerias = feriasProporcional + feriasVencidasValor;
      final tercoFerias = totalFerias / 3;

      final fgtsSaldoEstimado = baseCalculo * 0.08 * mesesTrabalhadosTotal;
      double multaFgts = 0;
      if (input.tipoDesligamento == 'Sem justa causa') {
        multaFgts = fgtsSaldoEstimado * 0.40;
      } else if (input.tipoDesligamento == 'Acordo mútuo') {
        multaFgts = fgtsSaldoEstimado * 0.20;
      }

      final inss = _calculateInss(
        saldoSalario + valorInsalubridade + horasExtrasValor,
      );
      final irrf = _calculateIrrf(
        (saldoSalario + valorInsalubridade + horasExtrasValor) - inss,
        input.dependentes,
      );

      final totalBruto =
          saldoSalario +
          valorInsalubridade +
          horasExtrasValor +
          avisoPrevioValor +
          decimoTerceiro +
          feriasProporcional +
          feriasVencidasValor +
          tercoFerias +
          multaFgts;
      final totalDescontos = inss + irrf;

      state = state.copyWith(
        isLoading: false,
        result: CalculatorResult(
          saldoSalario: saldoSalario,
          avisoPrevio: avisoPrevioValor,
          decimoTerceiroProporcional: decimoTerceiro,
          feriasProporcional: feriasProporcional,
          tercoFerias: tercoFerias,
          feriasVencidas: feriasVencidasValor,
          multaFgts: multaFgts,
          fgtsDeposito: fgtsSaldoEstimado,
          inss: inss,
          irrf: irrf,
          totalBruto: totalBruto,
          totalDescontos: totalDescontos,
          totalLiquido: totalBruto - totalDescontos,
          mesesTrabalhados: mesesTrabalhadosTotal,
          insalubridade: valorInsalubridade,
          horasExtrasValor: horasExtrasValor,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  int _calculateMonths(DateTime admissao, DateTime demissao) {
    int months =
        (demissao.year - admissao.year) * 12 + demissao.month - admissao.month;
    return months < 0 ? 0 : months;
  }

  double _calculateInss(double salary) {
    if (salary <= 1621.00) return salary * 0.075;
    if (salary <= 2902.84)
      return (1621.00 * 0.075) + ((salary - 1621.00) * 0.09);
    if (salary <= 4354.27)
      return (1621.00 * 0.075) + (1281.84 * 0.09) + ((salary - 2902.84) * 0.12);
    if (salary <= 8475.55)
      return (1621.00 * 0.075) +
          (1281.84 * 0.09) +
          (1451.43 * 0.12) +
          ((salary - 4354.27) * 0.14);
    return 951.00;
  }

  double _calculateIrrf(double base, int dependentes) {
    double baseCalculo = base - (dependentes * 189.59);
    if (baseCalculo <= 5000.00) return 0;
    return (baseCalculo * 0.275) - 896.00;
  }
}

// 3. DEFINIÇÃO DO PROVIDER PARA RIVERPOD 3.x
final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(() {
      return CalculatorViewModel();
    });

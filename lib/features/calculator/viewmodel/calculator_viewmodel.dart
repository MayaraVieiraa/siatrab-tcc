import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Modelos
class CalculatorInput {
  final double salary;
  final String tipoAviso;
  final String feriasVencidas;
  final int dependentes;
  final DateTime dataAdmissao;
  final DateTime dataDemissao;
  final String insalubridade;
  final int horasExtras;
  final int horasExtrasFeriados;
  final String tipoDesligamento;
  final bool empregadorDispensouAviso;

  CalculatorInput({
    required this.salary,
    required this.tipoAviso,
    required this.feriasVencidas,
    required this.dependentes,
    required this.dataAdmissao,
    required this.dataDemissao,
    required this.insalubridade,
    required this.horasExtras,
    this.horasExtrasFeriados = 0,
    required this.tipoDesligamento,
    this.empregadorDispensouAviso = false,
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
  final double fgtsSaqueDisponivel;
  final double inss;
  final double irrf;
  final double totalBruto;
  final double totalDescontos;
  final double descontoAviso;
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
    required this.fgtsSaqueDisponivel,
    required this.inss,
    required this.irrf,
    required this.totalBruto,
    required this.totalDescontos,
    this.descontoAviso = 0.0,
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

// 2. ViewModel
class CalculatorViewModel extends Notifier<CalculatorState> {
  @override
  CalculatorState build() {
    return CalculatorState();
  }

  void clear() {
    state = CalculatorState();
  }

  Future<void> calculate(CalculatorInput input) async {
    state = state.copyWith(isLoading: true);

    try {
      // -----------------------------------------------------------------
      // Referências legais 2026
      // Salário mínimo: Decreto nº 12.797/2025
      // INSS: Portaria Interministerial MPS/MF nº 02/2026
      // IRRF: Lei nº 14.848/2024
      // Aviso prévio: Lei nº 12.506/2011
      // Acordo mútuo: Art. 484-A da CLT
      // Horas extras: Portaria nº 3.665/2023 (100% domingos/feriados)
      // -----------------------------------------------------------------
      const double salarioMinimo = 1621.00;
      final diasNoMesDemissao = input.dataDemissao.day;

      final int mesesTrabalhadosTotal = _calculateMonthsTotal(
        input.dataAdmissao,
        input.dataDemissao,
      );

      // Insalubridade integral (base: salário mínimo — Art. 192 CLT)
      double valorInsalubridade = 0;
      if (input.insalubridade.contains('10%'))
        valorInsalubridade = salarioMinimo * 0.10;
      if (input.insalubridade.contains('20%'))
        valorInsalubridade = salarioMinimo * 0.20;
      if (input.insalubridade.contains('40%'))
        valorInsalubridade = salarioMinimo * 0.40;

      final double baseCalculo = input.salary + valorInsalubridade;

      // Saldo de salário e insalubridade proporcionais aos dias do mês da saída
      final double saldoSalario = (input.salary / 30) * diasNoMesDemissao;
      final double insalubridadeProporcional =
          (valorInsalubridade / 30) * diasNoMesDemissao;

      // Horas extras
      final double valorHoraNormal = baseCalculo / 220;
      final double horasExtrasValor =
          (input.horasExtras * valorHoraNormal * 1.5) +
          (input.horasExtrasFeriados * valorHoraNormal * 2.0);

      // Aviso prévio proporcional (Lei nº 12.506/2011)
      final int anosCompletos =
          input.dataDemissao.difference(input.dataAdmissao).inDays ~/ 365;
      int diasAviso = 30 + (anosCompletos * 3);
      if (diasAviso > 90) diasAviso = 90; // Limite legal

      double avisoPrevioValor = 0;
      double descontoAviso = 0;
      DateTime dataProjetada = input.dataDemissao;

      // Ajuste por modalidade de desligamento
      if (input.tipoDesligamento == 'Sem justa causa') {
        if (input.tipoAviso == 'Indenizado') {
          avisoPrevioValor = (baseCalculo / 30) * diasAviso;
          dataProjetada = input.dataDemissao.add(Duration(days: diasAviso));
        }
      } else if (input.tipoDesligamento == 'Acordo mútuo') {
        if (input.tipoAviso == 'Indenizado') {
          avisoPrevioValor = ((baseCalculo / 30) * diasAviso) * 0.5; // 50%
          dataProjetada = input.dataDemissao.add(Duration(days: diasAviso));
        } else if (input.tipoAviso == 'Trabalhado') {
          avisoPrevioValor = (baseCalculo / 30) * diasAviso; // 100%
        }
      } else if (input.tipoDesligamento == 'Pedido de demissão') {
        if (input.tipoAviso == 'Indenizado' &&
            !input.empregadorDispensouAviso) {
          descontoAviso = baseCalculo;
        }
      }

      // Férias Proporcionais + 1/3
      double feriasProporcional = 0;
      double tercoFerias = 0;
      double feriasVencidasValor = 0;

      if (input.tipoDesligamento != 'Com justa causa') {
        int mesesNoPeriodoAquisitivo = _calcularMesesNoPeriodoAquisitivo(
          input.dataAdmissao,
          dataProjetada,
        );
        int mesesFerias = mesesNoPeriodoAquisitivo % 12;
        if (mesesFerias == 0 && mesesNoPeriodoAquisitivo > 0) {
          mesesFerias = 12; // Completou um período aquisitivo
        }

        feriasProporcional = (baseCalculo / 12) * mesesFerias;

        final double diasFeriasVencidas =
            double.tryParse(
              input.feriasVencidas.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;
        feriasVencidasValor = (baseCalculo / 30) * diasFeriasVencidas;
      }

      tercoFerias = (feriasProporcional + feriasVencidasValor) / 3;

      // 13º Salário Proporcional
      double decimoTerceiro = 0;
      if (input.tipoDesligamento != 'Com justa causa') {
        int meses13 = _calcularMesesDecimoTerceiro(
          input.dataAdmissao,
          dataProjetada,
        );
        decimoTerceiro = (baseCalculo / 12) * meses13;
      }

      // FGTS (Art. 15 Lei nº 8.036/90)
      final double fgtsSaldoEstimado =
          baseCalculo * 0.08 * mesesTrabalhadosTotal;
      double multaFgts = 0;
      double fgtsSaqueDisponivel = 0;

      if (input.tipoDesligamento == 'Sem justa causa') {
        multaFgts = fgtsSaldoEstimado * 0.40;
        fgtsSaqueDisponivel = fgtsSaldoEstimado;
      } else if (input.tipoDesligamento == 'Acordo mútuo') {
        multaFgts = fgtsSaldoEstimado * 0.20;
        fgtsSaqueDisponivel = fgtsSaldoEstimado * 0.80;
      }

      // Descontos do Mês
      final double baseDescontosMes =
          saldoSalario + insalubridadeProporcional + horasExtrasValor;
      final double inssMes = _calculateInss(baseDescontosMes);
      final double irrfMes = _calculateIrrf(
        baseDescontosMes - inssMes,
        input.dependentes,
      );

      // Descontos do 13º Salário
      final double inss13 = _calculateInss(decimoTerceiro);
      final double irrf13 = _calculateIrrf(
        decimoTerceiro - inss13,
        input.dependentes,
      );

      final double inssTotal = inssMes + inss13;
      final double irrfTotal = irrfMes + irrf13;

      final double totalBruto =
          saldoSalario +
          insalubridadeProporcional +
          horasExtrasValor +
          avisoPrevioValor +
          decimoTerceiro +
          feriasProporcional +
          feriasVencidasValor +
          tercoFerias +
          multaFgts;

      final double totalDescontos = inssTotal + irrfTotal + descontoAviso;

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
          fgtsSaqueDisponivel: fgtsSaqueDisponivel,
          inss: inssTotal,
          irrf: irrfTotal,
          totalBruto: totalBruto,
          totalDescontos: totalDescontos,
          descontoAviso: descontoAviso,
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

  int _calculateMonthsTotal(DateTime admissao, DateTime demissao) {
    int months =
        (demissao.year - admissao.year) * 12 +
        (demissao.month - admissao.month);

    if (demissao.day >= admissao.day) {
      months++;
    }
    return months < 0 ? 0 : months;
  }

  int _calcularMesesNoPeriodoAquisitivo(
    DateTime admissao,
    DateTime dataProjetada,
  ) {
    int dias = dataProjetada.difference(admissao).inDays;
    int meses = dias ~/ 30;
    if (dias % 30 >= 15) meses++;
    return meses;
  }

  int _calcularMesesDecimoTerceiro(DateTime admissao, DateTime dataProjetada) {
    int meses = 0;
    DateTime inicio = admissao;
    DateTime fim = dataProjetada;

    // Se a admissão foi em ano anterior, começa de janeiro
    if (admissao.year < dataProjetada.year) {
      inicio = DateTime(dataProjetada.year, 1, 1);
    }

    for (int mes = inicio.month; mes <= fim.month; mes++) {
      DateTime ultimoDiaMes = DateTime(fim.year, mes + 1, 0);

      if (inicio.month == fim.month) {
        // Admissão e demissão no mesmo mês
        int diasTrabalhados = fim.day - inicio.day + 1;
        if (diasTrabalhados >= 15) meses++;
      } else if (mes == inicio.month) {
        // Primeiro mês: verifica dias trabalhados a partir da admissão
        int diasTrabalhados = ultimoDiaMes.day - inicio.day + 1;
        if (diasTrabalhados >= 15) meses++;
      } else if (mes == fim.month) {
        // Último mês: verifica dias até a demissão
        if (fim.day >= 15) meses++;
      } else {
        // Mês completo
        meses++;
      }
    }

    return meses;
  }

  // INSS 2026
  double _calculateInss(double salary) {
    if (salary <= 0) return 0;
    if (salary <= 1621.00) return salary * 0.075;
    if (salary <= 2902.84)
      return (1621.00 * 0.075) + ((salary - 1621.00) * 0.09);
    if (salary <= 4354.27)
      return (1621.00 * 0.075) + (1281.84 * 0.09) + ((salary - 2902.84) * 0.12);
    if (salary <= 8475.55) {
      return (1621.00 * 0.075) +
          (1281.84 * 0.09) +
          (1451.43 * 0.12) +
          ((salary - 4354.27) * 0.14);
    }
    return 951.00; // Teto
  }

  // IRRF 2026
  double _calculateIrrf(double base, int dependentes) {
    if (base <= 0) return 0;
    final double baseCalculo = base - (dependentes * 189.59);
    if (baseCalculo <= 5000.00) return 0;
    if (baseCalculo <= 6000.00) return (baseCalculo * 0.075) - 375.00;
    if (baseCalculo <= 7500.00) return (baseCalculo * 0.15) - 825.00;
    if (baseCalculo <= 9000.00) return (baseCalculo * 0.225) - 1500.00;
    return (baseCalculo * 0.275) - 2400.00;
  }
}

// 3. Provider
final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(() {
      return CalculatorViewModel();
    });

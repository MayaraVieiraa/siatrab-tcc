import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// REFERÊNCIAS LEGAIS 2026
// =============================================================================
// Salário mínimo:  Decreto nº 12.797/2025 → R$ 1.621,00
// INSS:            Portaria Interministerial MPS/MF nº 02/2026
// IRRF:            Lei nº 14.848/2024 (isenção até R$ 5.000,00)
// Aviso prévio:    Art. 487 CLT + Lei nº 12.506/2011 (proporcional)
// Rescisão:        Art. 477 CLT
// Acordo mútuo:    Art. 484-A CLT
// FGTS:            Art. 15 e 18 da Lei nº 8.036/90
// 13º salário:     Lei nº 4.090/62
// Férias:          Arts. 129, 130 CLT + Art. 7º, XVII CF/88
// Horas extras:    Art. 59 CLT + Portaria nº 3.665/2023
// Insalubridade:   Art. 192 CLT (base: salário mínimo)
// =============================================================================

// -----------------------------------------------------------------------------
// 1. MODELOS DE ENTRADA E SAÍDA
// -----------------------------------------------------------------------------

class CalculatorInput {
  final double salary;
  final String tipoAviso; // 'Indenizado' ou 'Trabalhado'
  final int feriasVencidasDias; // Dias de férias vencidas (ex: 30, 0)
  final int dependentes;
  final DateTime dataAdmissao;
  final DateTime dataDemissao;
  final String insalubridade; // '10%', '20%', '40%' ou 'Nenhum'
  final int horasExtras; // Horas extras em dias úteis (50%)
  final int horasExtrasFeriados; // Horas extras em domingos/feriados (100%)
  final String
  tipoDesligamento; // 'Sem justa causa', 'Pedido de demissão', 'Acordo mútuo', 'Com justa causa'
  final bool empregadorDispensouAviso; // Apenas para pedido de demissão

  CalculatorInput({
    required this.salary,
    required this.tipoAviso,
    required this.feriasVencidasDias,
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
  final double insalubridadeProporcional;
  final double horasExtrasValor;
  final double avisoPrevio;
  final double decimoTerceiroProporcional;
  final double feriasProporcional;
  final double tercoFeriasProporcional;
  final double feriasVencidas;
  final double tercoFeriasVencidas;
  final double multaFgts;
  final double fgtsDepositoEstimado;
  final double fgtsSaqueDisponivel;
  final double inss;
  final double irrf;
  final double descontoAviso;
  final double totalBruto;
  final double totalDescontos;
  final double totalLiquido;
  final int mesesTrabalhados;
  final int diasAviso;
  final int anosCompletos;

  CalculatorResult({
    required this.saldoSalario,
    required this.insalubridadeProporcional,
    required this.horasExtrasValor,
    required this.avisoPrevio,
    required this.decimoTerceiroProporcional,
    required this.feriasProporcional,
    required this.tercoFeriasProporcional,
    required this.feriasVencidas,
    required this.tercoFeriasVencidas,
    required this.multaFgts,
    required this.fgtsDepositoEstimado,
    required this.fgtsSaqueDisponivel,
    required this.inss,
    required this.irrf,
    required this.descontoAviso,
    required this.totalBruto,
    required this.totalDescontos,
    required this.totalLiquido,
    required this.mesesTrabalhados,
    required this.diasAviso,
    required this.anosCompletos,
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

// -----------------------------------------------------------------------------
// 2. VIEWMODEL (VERSÃO COM FGTS AUTOMÁTICO)
// -----------------------------------------------------------------------------

class CalculatorViewModel extends Notifier<CalculatorState> {
  // ==========================================================================
  // CONSTANTES CENTRALIZADAS 2026 (fácil manutenção anual)
  // ==========================================================================
  static const double SALARIO_MINIMO = 1621.00; // Decreto nº 12.797/2025
  static const double DEDUCAO_POR_DEPENDENTE = 189.59; // IRRF 2026
  static const double FAIXA_ISENCAO_IRRF = 5000.00; // Lei nº 14.848/2024
  static const double TETO_INSS =
      951.00; // Portaria Interministerial MPS/MF nº 02/2026

  // Tabela INSS 2026
  static const double INSS_FAIXA1_TETO = 1621.00;
  static const double INSS_FAIXA1_ALIQUOTA = 0.075;
  static const double INSS_FAIXA2_TETO = 2902.84;
  static const double INSS_FAIXA2_ALIQUOTA = 0.09;
  static const double INSS_FAIXA3_TETO = 4354.27;
  static const double INSS_FAIXA3_ALIQUOTA = 0.12;
  static const double INSS_FAIXA4_TETO = 8475.55;
  static const double INSS_FAIXA4_ALIQUOTA = 0.14;

  // Tabela IRRF 2026
  static const double IRRF_FAIXA1_TETO = 6000.00;
  static const double IRRF_FAIXA1_ALIQUOTA = 0.075;
  static const double IRRF_FAIXA1_DEDUCAO = 375.00;
  static const double IRRF_FAIXA2_TETO = 7500.00;
  static const double IRRF_FAIXA2_ALIQUOTA = 0.15;
  static const double IRRF_FAIXA2_DEDUCAO = 825.00;
  static const double IRRF_FAIXA3_TETO = 9000.00;
  static const double IRRF_FAIXA3_ALIQUOTA = 0.225;
  static const double IRRF_FAIXA3_DEDUCAO = 1500.00;
  static const double IRRF_FAIXA4_ALIQUOTA = 0.275;
  static const double IRRF_FAIXA4_DEDUCAO = 2400.00;

  @override
  CalculatorState build() => CalculatorState();

  void clear() => state = CalculatorState();

  Future<void> calculate(CalculatorInput i) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // -----------------------------------------------------------------------
      // DADOS TEMPORAIS BÁSICOS
      // -----------------------------------------------------------------------
      final int diasNoMesDemissao = i.dataDemissao.day;

      // Meses totais trabalhados (para referência)
      final int mesesTrabalhadosTotal = _mesesEntreDatas(
        i.dataAdmissao,
        i.dataDemissao,
      );

      // -----------------------------------------------------------------------
      // INSALUBRIDADE (Art. 192 CLT)
      // Base: salário mínimo, NÃO o salário do trabalhador
      // -----------------------------------------------------------------------
      double valorInsalubridade = 0;
      if (i.insalubridade.contains('10%')) {
        valorInsalubridade = SALARIO_MINIMO * 0.10;
      } else if (i.insalubridade.contains('20%')) {
        valorInsalubridade = SALARIO_MINIMO * 0.20;
      } else if (i.insalubridade.contains('40%')) {
        valorInsalubridade = SALARIO_MINIMO * 0.40;
      }

      // -----------------------------------------------------------------------
      // BASE DE CÁLCULO PARA VERBAS RESCISÓRIAS
      // -----------------------------------------------------------------------
      final double baseCalculo = i.salary + valorInsalubridade;

      // Saldo de salário e insalubridade proporcionais
      final double saldoSalario = (i.salary / 30) * diasNoMesDemissao;
      final double insalubProp = (valorInsalubridade / 30) * diasNoMesDemissao;

      // -----------------------------------------------------------------------
      // HORAS EXTRAS (Art. 59 CLT + Portaria nº 3.665/2023)
      // Dias úteis: 50% | Domingos/feriados: 100%
      // -----------------------------------------------------------------------
      final double valorHoraNormal = baseCalculo / 220;
      final double horasExtrasValor =
          (i.horasExtras * valorHoraNormal * 1.5) +
          (i.horasExtrasFeriados * valorHoraNormal * 2.0);

      // Média mensal de horas extras para integrar 13º e férias (Súmula 347 TST)
      final double mediaHorasExtrasMensal = _calcularMediaHorasExtras(
        i.horasExtras,
        i.horasExtrasFeriados,
        baseCalculo,
      );

      // -----------------------------------------------------------------------
      // BASE PARA 13º E FÉRIAS (inclui horas extras - Súmula 347 TST)
      // -----------------------------------------------------------------------
      final double basePara13eFerias = baseCalculo + mediaHorasExtrasMensal;

      // -----------------------------------------------------------------------
      // AVISO PRÉVIO PROPORCIONAL (Art. 487 CLT + Lei nº 12.506/2011)
      // -----------------------------------------------------------------------
      final int anosCompletos = _anosCompletosEntreDatas(
        i.dataAdmissao,
        i.dataDemissao,
      );
      final int diasAviso = (30 + (anosCompletos * 3)).clamp(30, 90);

      DateTime dataProjetada = i.dataDemissao;
      double avisoPrevioValor = 0;
      double descontoAviso = 0;

      switch (i.tipoDesligamento) {
        case 'Sem justa causa':
          if (i.tipoAviso == 'Indenizado') {
            avisoPrevioValor = (baseCalculo / 30) * diasAviso;
            dataProjetada = i.dataDemissao.add(Duration(days: diasAviso));
          }
          break;

        case 'Acordo mútuo':
          // Art. 484-A CLT: aviso indenizado = 50%
          if (i.tipoAviso == 'Indenizado') {
            avisoPrevioValor = ((baseCalculo / 30) * diasAviso) * 0.5;
            dataProjetada = i.dataDemissao.add(Duration(days: diasAviso));
          }
          break;

        case 'Pedido de demissão':
          if (i.tipoAviso == 'Indenizado' && !i.empregadorDispensouAviso) {
            descontoAviso = (baseCalculo / 30) * diasAviso;
          }
          break;

        case 'Com justa causa':
          // Sem aviso prévio
          break;
      }

      // -----------------------------------------------------------------------
      // FÉRIAS PROPORCIONAIS + 1/3 (Art. 7º, XVII CF/88 + Arts. 129-130 CLT)
      // -----------------------------------------------------------------------
      double feriasProporcional = 0;
      double tercoFeriasProporcional = 0;

      if (i.tipoDesligamento != 'Com justa causa') {
        final int mesesAquisitivos = _mesesNoPeriodoAquisitivo(
          i.dataAdmissao,
          dataProjetada,
        );

        feriasProporcional = (basePara13eFerias / 12) * mesesAquisitivos;
        tercoFeriasProporcional = feriasProporcional / 3;
      }

      // -----------------------------------------------------------------------
      // FÉRIAS VENCIDAS (período anterior completo não gozado)
      // -----------------------------------------------------------------------
      double feriasVencidasValor = 0;
      double tercoFeriasVencidas = 0;

      if (i.feriasVencidasDias > 0) {
        feriasVencidasValor = (basePara13eFerias / 30) * i.feriasVencidasDias;
        tercoFeriasVencidas = feriasVencidasValor / 3;
      }

      // -----------------------------------------------------------------------
      // 13º SALÁRIO PROPORCIONAL (Lei nº 4.090/62)
      // -----------------------------------------------------------------------
      double decimoTerceiro = 0;

      if (i.tipoDesligamento != 'Com justa causa') {
        final int avos13 = _avosDecimoTerceiro(i.dataAdmissao, dataProjetada);
        decimoTerceiro = (basePara13eFerias / 12) * avos13;
      }

      // -----------------------------------------------------------------------
      // FGTS - CÁLCULO AUTOMÁTICO (Art. 15 e 18 da Lei nº 8.036/90)
      // ✅ O FGTS é calculado automaticamente, sem depender do usuário
      // ✅ Inclui projeção de 13º e 1/3 de férias
      // =========================================================================
      final double fatorProporcionalAnual = 1 + (1 / 12) + (1 / 36);
      final double fgtsDepositoEstimado =
          (baseCalculo * 0.08) * mesesTrabalhadosTotal * fatorProporcionalAnual;

      double multaFgts = 0;
      double fgtsSaqueDisponivel = 0;

      switch (i.tipoDesligamento) {
        case 'Sem justa causa':
          multaFgts = fgtsDepositoEstimado * 0.40;
          fgtsSaqueDisponivel = fgtsDepositoEstimado;
          break;

        case 'Acordo mútuo':
          multaFgts = fgtsDepositoEstimado * 0.20; // Art. 484-A CLT
          fgtsSaqueDisponivel = fgtsDepositoEstimado * 0.80;
          break;

        default:
          multaFgts = 0;
          fgtsSaqueDisponivel = 0;
      }

      // -----------------------------------------------------------------------
      // DESCONTOS — INSS E IRRF
      // -----------------------------------------------------------------------
      final double baseMes = saldoSalario + insalubProp + horasExtrasValor;
      final double inssMes = _calculateInss(baseMes);
      final double irrfMes = _calculateIrrf(baseMes - inssMes, i.dependentes);

      final double inss13 = _calculateInss(decimoTerceiro);
      final double irrf13 = _calculateIrrf(
        decimoTerceiro - inss13,
        i.dependentes,
      );

      final double inssTotal = inssMes + inss13;
      final double irrfTotal = irrfMes + irrf13;

      // -----------------------------------------------------------------------
      // TOTAIS FINAIS
      // -----------------------------------------------------------------------
      final double totalBruto =
          saldoSalario +
          insalubProp +
          horasExtrasValor +
          avisoPrevioValor +
          decimoTerceiro +
          feriasProporcional +
          tercoFeriasProporcional +
          feriasVencidasValor +
          tercoFeriasVencidas +
          multaFgts;

      final double totalDescontos = inssTotal + irrfTotal + descontoAviso;

      state = state.copyWith(
        isLoading: false,
        result: CalculatorResult(
          saldoSalario: saldoSalario,
          insalubridadeProporcional: insalubProp,
          horasExtrasValor: horasExtrasValor,
          avisoPrevio: avisoPrevioValor,
          decimoTerceiroProporcional: decimoTerceiro,
          feriasProporcional: feriasProporcional,
          tercoFeriasProporcional: tercoFeriasProporcional,
          feriasVencidas: feriasVencidasValor,
          tercoFeriasVencidas: tercoFeriasVencidas,
          multaFgts: multaFgts,
          fgtsDepositoEstimado: fgtsDepositoEstimado,
          fgtsSaqueDisponivel: fgtsSaqueDisponivel,
          inss: inssTotal,
          irrf: irrfTotal,
          descontoAviso: descontoAviso,
          totalBruto: totalBruto,
          totalDescontos: totalDescontos,
          totalLiquido: totalBruto - totalDescontos,
          mesesTrabalhados: mesesTrabalhadosTotal,
          diasAviso: diasAviso,
          anosCompletos: anosCompletos,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  /// Calcula média mensal de horas extras para integrar 13º e férias
  /// (Súmula 347 do TST)
  double _calcularMediaHorasExtras(
    int horasNormais,
    int horasFeriados,
    double baseCalculo,
  ) {
    if (horasNormais == 0 && horasFeriados == 0) return 0;

    final double valorHora = baseCalculo / 220;
    final double valorTotalHoras =
        (horasNormais * valorHora * 1.5) + (horasFeriados * valorHora * 2.0);

    return valorTotalHoras;
  }

  /// Anos COMPLETOS entre duas datas usando calendário gregoriano.
  int _anosCompletosEntreDatas(DateTime inicio, DateTime fim) {
    int anos = fim.year - inicio.year;
    if (fim.month < inicio.month ||
        (fim.month == inicio.month && fim.day < inicio.day)) {
      anos--;
    }
    return anos < 0 ? 0 : anos;
  }

  /// Meses COMPLETOS entre duas datas (para FGTS e referência)
  int _mesesEntreDatas(DateTime inicio, DateTime fim) {
    int meses = (fim.year - inicio.year) * 12 + (fim.month - inicio.month);
    if (fim.day >= inicio.day) meses++;
    return meses < 0 ? 0 : meses;
  }

  /// Meses no período aquisitivo ATUAL de férias
  int _mesesNoPeriodoAquisitivo(DateTime admissao, DateTime dataProjetada) {
    final int totalMeses = _mesesEntreDatas(admissao, dataProjetada);
    int mesesNoPeriodo = totalMeses % 12;
    if (mesesNoPeriodo == 0 && totalMeses > 0) mesesNoPeriodo = 12;
    return mesesNoPeriodo;
  }

  /// Avos do 13º salário (suporta virada de ano)
  int _avosDecimoTerceiro(DateTime admissao, DateTime dataProjetada) {
    int avos = 0;

    for (int ano = admissao.year; ano <= dataProjetada.year; ano++) {
      final int mesInicio = (ano == admissao.year) ? admissao.month : 1;
      final int mesFim = (ano == dataProjetada.year) ? dataProjetada.month : 12;

      for (int mes = mesInicio; mes <= mesFim; mes++) {
        final DateTime ultimoDiaMes = DateTime(ano, mes + 1, 0);

        final int diaInicio = (ano == admissao.year && mes == admissao.month)
            ? admissao.day
            : 1;

        final int diaFim =
            (ano == dataProjetada.year && mes == dataProjetada.month)
            ? dataProjetada.day
            : ultimoDiaMes.day;

        final int diasTrabalhados = diaFim - diaInicio + 1;

        if (diasTrabalhados >= 15) avos++;
      }
    }

    return avos;
  }

  // ==========================================================================
  // INSS 2026 (usando constantes centralizadas)
  // ==========================================================================
  double _calculateInss(double salary) {
    if (salary <= 0) return 0;

    if (salary <= INSS_FAIXA1_TETO) {
      return salary * INSS_FAIXA1_ALIQUOTA;
    }

    if (salary <= INSS_FAIXA2_TETO) {
      return (INSS_FAIXA1_TETO * INSS_FAIXA1_ALIQUOTA) +
          ((salary - INSS_FAIXA1_TETO) * INSS_FAIXA2_ALIQUOTA);
    }

    if (salary <= INSS_FAIXA3_TETO) {
      return (INSS_FAIXA1_TETO * INSS_FAIXA1_ALIQUOTA) +
          ((INSS_FAIXA2_TETO - INSS_FAIXA1_TETO) * INSS_FAIXA2_ALIQUOTA) +
          ((salary - INSS_FAIXA2_TETO) * INSS_FAIXA3_ALIQUOTA);
    }

    if (salary <= INSS_FAIXA4_TETO) {
      return (INSS_FAIXA1_TETO * INSS_FAIXA1_ALIQUOTA) +
          ((INSS_FAIXA2_TETO - INSS_FAIXA1_TETO) * INSS_FAIXA2_ALIQUOTA) +
          ((INSS_FAIXA3_TETO - INSS_FAIXA2_TETO) * INSS_FAIXA3_ALIQUOTA) +
          ((salary - INSS_FAIXA3_TETO) * INSS_FAIXA4_ALIQUOTA);
    }

    return TETO_INSS;
  }

  // ==========================================================================
  // IRRF 2026 (usando constantes centralizadas)
  // ==========================================================================
  double _calculateIrrf(double base, int dependentes) {
    if (base <= 0) return 0;

    final double baseCalculo = base - (dependentes * DEDUCAO_POR_DEPENDENTE);

    if (baseCalculo <= FAIXA_ISENCAO_IRRF) return 0;
    if (baseCalculo <= IRRF_FAIXA1_TETO) {
      return (baseCalculo * IRRF_FAIXA1_ALIQUOTA) - IRRF_FAIXA1_DEDUCAO;
    }
    if (baseCalculo <= IRRF_FAIXA2_TETO) {
      return (baseCalculo * IRRF_FAIXA2_ALIQUOTA) - IRRF_FAIXA2_DEDUCAO;
    }
    if (baseCalculo <= IRRF_FAIXA3_TETO) {
      return (baseCalculo * IRRF_FAIXA3_ALIQUOTA) - IRRF_FAIXA3_DEDUCAO;
    }
    return (baseCalculo * IRRF_FAIXA4_ALIQUOTA) - IRRF_FAIXA4_DEDUCAO;
  }
}

// -----------------------------------------------------------------------------
// 3. PROVIDER
// -----------------------------------------------------------------------------

final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(
      CalculatorViewModel.new,
    );

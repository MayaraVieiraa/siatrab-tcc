// Funções tributárias centralizadas — evita duplicação entre páginas
// INSS: Portaria Interministerial MPS/MF nº 02/2026
// IRRF: Lei nº 14.848/2024

double calculateInss(double salary) {
  if (salary <= 0) return 0;
  if (salary <= 1621.00) return salary * 0.075;
  if (salary <= 2902.84) return (1621.00 * 0.075) + ((salary - 1621.00) * 0.09);
  if (salary <= 4354.27)
    return (1621.00 * 0.075) + (1281.84 * 0.09) + ((salary - 2902.84) * 0.12);
  if (salary <= 8475.55)
    return (1621.00 * 0.075) +
        (1281.84 * 0.09) +
        (1451.43 * 0.12) +
        ((salary - 4354.27) * 0.14);
  return 951.00; // teto
}

// IRRF: isenção até R$ 5.000,00 — tabela progressiva com 5 faixas
// Dedução por dependente: R$ 189,59
double calculateIrrf(double base, int dependentes) {
  final double baseCalculo = base - (dependentes * 189.59);
  if (baseCalculo <= 0) return 0;
  if (baseCalculo <= 5000.00) return 0;
  if (baseCalculo <= 6000.00) return (baseCalculo * 0.075) - 375.00;
  if (baseCalculo <= 7500.00) return (baseCalculo * 0.15) - 825.00;
  if (baseCalculo <= 9000.00) return (baseCalculo * 0.225) - 1500.00;
  return (baseCalculo * 0.275) - 2400.00;
}

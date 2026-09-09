# VSFilterMod r5.3.1 Vmoe — código-fonte

Esta é a base `VSFilterMod-r5.3.1` com as funcionalidades da seção
“New tags in Vmoe mod” portadas da `r5.2.7-beta`.

Os commits exatos de origem, arquivos adaptados e estado da validação estão
registrados em [`PORTING.md`](PORTING.md).

## Tags incluídas

- `\ortho0` e `\ortho1`: projeção em perspectiva ou ortogonal;
- `\xblur` e `\yblur`: desfoque direcional animável;
- `\fshp`: espaçamento horizontal animável;
- `\blend0` a `\blend6` e formas textuais: modos de composição de cor.

Os modos textuais aceitos são `over`, `add`, `sub`, `mult`, `scr` e `diff`.

## Ambiente necessário

- Windows 10 ou mais recente;
- Visual Studio com “Desenvolvimento para Desktop com C++”;
- componente “C++ MFC para as ferramentas de build x64/x86 mais recentes”;
- Windows 10 SDK;
- um toolset MSVC compatível instalado.

Os scripts localizam o Visual Studio automaticamente e configuram seu ambiente.
Não é necessário abrir previamente o Native Tools Command Prompt.

## Compilação

Clique duas vezes no script desejado ou execute-o em um Prompt de Comando:

```bat
build_x64.bat
build_x86.bat
build_all.bat
```

Os scripts detectam `v145`, `v143` ou `v142` a partir das ferramentas MSVC
ativas. Se houver mais de um toolset instalado, ele pode ser informado:

```bat
build_x64.bat v143
build_all.bat v145
```

Também é possível definir `VSFILTERMOD_TOOLSET` antes de executar o script.

`build_all.bat` compila as duas arquiteturas. Os resultados são copiados para:

```text
dist\x64\VSFilterMod.dll
dist\x86\VSFilterMod.dll
```

Use a arquitetura correspondente ao aplicativo que carregará o filtro.

## Observações

- A configuração usada é `Release (MOD)`.
- O script faz uma recompilação completa para evitar objetos antigos incompatíveis.
- As DLLs geradas localmente não terão assinatura digital.
- Avisos do compilador herdados do código legado podem aparecer; o script só considera
  a operação bem-sucedida quando a DLL final existe.
- Os ambientes confirmados são Visual Studio 2026 com `v145` localmente e
  Visual Studio 2022 com `v143` no GitHub Actions.
- Os projetos ainda declaram `v142`, como no upstream, mas esse toolset não foi
  validado neste port.
- O GitHub Actions permanece fixo em `v143` para garantir reprodutibilidade.

## Licença

O código preserva a licença GPL e os avisos de autoria da distribuição original.
Consulte `LICENSE` e os cabeçalhos dos arquivos-fonte.

-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 02-Abr-2022 às 21:11
-- Versão do servidor: 10.4.22-MariaDB
-- versão do PHP: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `agencia`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `cliente`
--

CREATE TABLE `cliente` (
  `cpf` varchar(14) NOT NULL,
  `nome` varchar(45) NOT NULL,
  `rg` varchar(12) NOT NULL,
  `estado_rg` char(2) NOT NULL,
  `endereco` varchar(45) NOT NULL,
  `telefone` varchar(15) NOT NULL,
  `email` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `cliente`
--

INSERT INTO `cliente` (`cpf`, `nome`, `rg`, `estado_rg`, `endereco`, `telefone`, `email`) VALUES
('234.567.890-10', 'Maria Costa', '32.345.567-1', 'RJ', 'Rua Y', '(19) 3342-5678', 'maria@uol.com.br'),
('264.557.323-00', 'José da Silva', '24.654.789-0', 'SP', 'Rua X', '(18) 99787-3323', 'jose@gmail.com');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `contagempasseiodoguia`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `contagempasseiodoguia` (
`nome_do_guia` varchar(45)
,`quantidade_passeios` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `contasareceber`
--

CREATE TABLE `contasareceber` (
  `parcela` int(11) NOT NULL,
  `data_vencimento` date NOT NULL,
  `valor_receber` float NOT NULL DEFAULT 0,
  `data_recebimento` date DEFAULT NULL,
  `valor_recebido` float DEFAULT 0,
  `contrato_numero` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `contasareceber`
--

INSERT INTO `contasareceber` (`parcela`, `data_vencimento`, `valor_receber`, `data_recebimento`, `valor_recebido`, `contrato_numero`) VALUES
(1, '2021-08-19', 166.667, '2021-08-19', 166.667, 10),
(2, '2021-09-19', 166.667, NULL, NULL, 10),
(3, '2021-10-19', 166.667, NULL, NULL, 10);

-- --------------------------------------------------------

--
-- Estrutura da tabela `contrato`
--

CREATE TABLE `contrato` (
  `numero` int(10) UNSIGNED NOT NULL,
  `pacote_codigo` int(11) NOT NULL,
  `cliente_cpf` varchar(14) NOT NULL,
  `valor` float NOT NULL DEFAULT 0,
  `data` date NOT NULL,
  `qtd_parcelas` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `contrato`
--

INSERT INTO `contrato` (`numero`, `pacote_codigo`, `cliente_cpf`, `valor`, `data`, `qtd_parcelas`) VALUES
(10, 1, '234.567.890-10', 500, '2021-08-19', 3);

--
-- Acionadores `contrato`
--
DELIMITER $$
CREATE TRIGGER `AlterarParcelas` AFTER UPDATE ON `contrato` FOR EACH ROW BEGIN
   declare i, auxiliar, qtdParcelas int ;
declare dataParcela Date;
select new.qtd_parcelas into qtdParcelas;
set i = 1;
Delete from ContasAReceber where  contrato_numero = new.numero;
while (i <= qtdParcelas) do
 if (i = 1 ) then
  insert into ContasAReceber (contrato_numero, parcela, data_vencimento, valor_receber, data_recebimento, valor_recebido)
  Values (new.numero,i, new.data, (new.valor / qtdParcelas), new.data, (new.valor / qtdParcelas));
 else
  set auxiliar = i - 1;
  set dataParcela = DATE_ADD(new.data, INTERVAL auxiliar month);
  insert into ContasAReceber (contrato_numero, parcela, data_vencimento, valor_receber, data_recebimento, valor_recebido)
   Values (new.numero,i, dataParcela, (new.valor / qtdParcelas), null, null);
 end if;
 set i = i + 1;
end while;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CriarParcelas` AFTER INSERT ON `contrato` FOR EACH ROW BEGIN
declare i, auxiliar, qtdParcelas int ;
declare dataParcela Date;
select new.qtd_parcelas into qtdParcelas;
set i = 1;
while (i <= qtdParcelas) do
 if (i = 1 ) then
  insert into ContasAReceber (contrato_numero, parcela, data_vencimento, valor_receber, data_recebimento, valor_recebido)
  Values (new.numero,i, new.data, (new.valor / qtdParcelas), new.data, (new.valor / qtdParcelas));
 else
  set auxiliar = i - 1;
  set dataParcela = DATE_ADD(new.data, INTERVAL auxiliar month);
  insert into ContasAReceber (contrato_numero, parcela, data_vencimento, valor_receber, data_recebimento, valor_recebido)
   Values (new.numero,i, dataParcela, (new.valor / qtdParcelas), null, null);
 end if;
 set i = i + 1;
end while;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `DeletarParcelas` BEFORE DELETE ON `contrato` FOR EACH ROW BEGIN
delete from ContasAReceber 
where contrato_numero = old.numero;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guia`
--

CREATE TABLE `guia` (
  `codigo` int(11) NOT NULL,
  `nome` varchar(45) NOT NULL,
  `apelido` varchar(20) NOT NULL,
  `endereco` varchar(45) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `guia`
--

INSERT INTO `guia` (`codigo`, `nome`, `apelido`, `endereco`, `telefone`) VALUES
(1, 'Ana Lucia', 'Nana', 'Av. A', '(21) 99764-5523'),
(2, 'Lucas de Almeida', 'Lu', 'Rua Z', '(84) 99787-2211');

-- --------------------------------------------------------

--
-- Estrutura da tabela `pacote`
--

CREATE TABLE `pacote` (
  `codigo` int(11) NOT NULL,
  `data_embarque` date NOT NULL,
  `data_retorno` date NOT NULL,
  `descricao` text NOT NULL,
  `preco` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `pacote`
--

INSERT INTO `pacote` (`codigo`, `data_embarque`, `data_retorno`, `descricao`, `preco`) VALUES
(1, '2021-08-17', '2021-08-24', 'Rio de Janeiro', 500),
(2, '2021-08-19', '2021-08-26', 'Natal', 150);

-- --------------------------------------------------------

--
-- Estrutura da tabela `passeio`
--

CREATE TABLE `passeio` (
  `codigo` int(11) NOT NULL,
  `partida` varchar(45) NOT NULL,
  `chegada` varchar(45) NOT NULL,
  `duracao` int(11) NOT NULL,
  `guia_codigo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `passeio`
--

INSERT INTO `passeio` (`codigo`, `partida`, `chegada`, `duracao`, `guia_codigo`) VALUES
(1, 'Centro', 'Cristo Redentor', 4, 1),
(2, 'Centro', 'Pão de Açucar', 3, 1),
(3, 'Morro do Careca', 'Praia da Pipa', 6, 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `passeiosdopacote`
--

CREATE TABLE `passeiosdopacote` (
  `pacote_codigo` int(11) NOT NULL,
  `passeio_codigo` int(11) NOT NULL,
  `data` date NOT NULL,
  `horario` time NOT NULL,
  `preco` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `passeiosdopacote`
--

INSERT INTO `passeiosdopacote` (`pacote_codigo`, `passeio_codigo`, `data`, `horario`, `preco`) VALUES
(1, 1, '2021-08-19', '13:00:00', 300),
(1, 2, '2021-08-21', '08:30:00', 200),
(2, 3, '2021-08-20', '09:00:00', 150);

--
-- Acionadores `passeiosdopacote`
--
DELIMITER $$
CREATE TRIGGER `AlterPrecodoPacote` AFTER UPDATE ON `passeiosdopacote` FOR EACH ROW BEGIN
  update pacote 
  set pacote.preco = pacote.preco - old.preco  + new.preco
  where pacote.codigo = new.pacote_codigo;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `DeletePrecoPacote` AFTER DELETE ON `passeiosdopacote` FOR EACH ROW BEGIN
update pacote 
set pacote.preco = pacote.preco - old.preco
where pacote.codigo = old.pacote_codigo;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `InsertPrecodoPacote` AFTER INSERT ON `passeiosdopacote` FOR EACH ROW BEGIN
 update pacote
 set pacote.preco = new.preco  + pacote.preco 
 where pacote.codigo = new.pacote_codigo;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para vista `contagempasseiodoguia`
--
DROP TABLE IF EXISTS `contagempasseiodoguia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `contagempasseiodoguia`  AS SELECT `g`.`nome` AS `nome_do_guia`, count(0) AS `quantidade_passeios` FROM (`guia` `g` join `passeio` `p`) WHERE `g`.`codigo` = `p`.`guia_codigo` GROUP BY `g`.`nome` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`cpf`);

--
-- Índices para tabela `contasareceber`
--
ALTER TABLE `contasareceber`
  ADD PRIMARY KEY (`parcela`,`contrato_numero`),
  ADD KEY `fk_ContasAReceber_contrato1_idx` (`contrato_numero`);

--
-- Índices para tabela `contrato`
--
ALTER TABLE `contrato`
  ADD PRIMARY KEY (`numero`),
  ADD UNIQUE KEY `valor_UNIQUE` (`valor`),
  ADD UNIQUE KEY `numero_UNIQUE` (`numero`),
  ADD KEY `fk_pacote_has_cliente_cliente1_idx` (`cliente_cpf`),
  ADD KEY `fk_pacote_has_cliente_pacote1_idx` (`pacote_codigo`);

--
-- Índices para tabela `guia`
--
ALTER TABLE `guia`
  ADD PRIMARY KEY (`codigo`);

--
-- Índices para tabela `pacote`
--
ALTER TABLE `pacote`
  ADD PRIMARY KEY (`codigo`);

--
-- Índices para tabela `passeio`
--
ALTER TABLE `passeio`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `fk_passeio_guia1_idx` (`guia_codigo`);

--
-- Índices para tabela `passeiosdopacote`
--
ALTER TABLE `passeiosdopacote`
  ADD PRIMARY KEY (`pacote_codigo`,`passeio_codigo`),
  ADD KEY `fk_pacote_has_passeio_passeio1_idx` (`passeio_codigo`),
  ADD KEY `fk_pacote_has_passeio_pacote_idx` (`pacote_codigo`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `contrato`
--
ALTER TABLE `contrato`
  MODIFY `numero` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de tabela `guia`
--
ALTER TABLE `guia`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `contasareceber`
--
ALTER TABLE `contasareceber`
  ADD CONSTRAINT `fk_ContasAReceber_contrato1` FOREIGN KEY (`contrato_numero`) REFERENCES `contrato` (`numero`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `contrato`
--
ALTER TABLE `contrato`
  ADD CONSTRAINT `fk_pacote_has_cliente_cliente1` FOREIGN KEY (`cliente_cpf`) REFERENCES `cliente` (`cpf`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_pacote_has_cliente_pacote1` FOREIGN KEY (`pacote_codigo`) REFERENCES `pacote` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `passeio`
--
ALTER TABLE `passeio`
  ADD CONSTRAINT `fk_passeio_guia1` FOREIGN KEY (`guia_codigo`) REFERENCES `guia` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `passeiosdopacote`
--
ALTER TABLE `passeiosdopacote`
  ADD CONSTRAINT `fk_pacote_has_passeio_pacote` FOREIGN KEY (`pacote_codigo`) REFERENCES `pacote` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_pacote_has_passeio_passeio1` FOREIGN KEY (`passeio_codigo`) REFERENCES `passeio` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

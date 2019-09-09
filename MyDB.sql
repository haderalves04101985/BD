CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

CREATE TABLE IF NOT EXISTS `mydb`.`veiculo` (
  `id_veiculo` INT NOT NULL AUTO_INCREMENT,
  `modelo_veiculo` VARCHAR(100) NOT NULL,
  `marca_veiculo` VARCHAR(100) NOT NULL,
  `ano_fabricacao_veiculo` INT(4) NOT NULL,
  `ano_modelo_veiculo` INT(4) NOT NULL,
  `placa_veiculo` VARCHAR(10) NULL,
  `chassi_veiculo` VARCHAR(20) NULL,
  `valor_veiculo` DECIMAL(10,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_veiculo`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`vendedor` (
  `id_vendedor` INT NOT NULL AUTO_INCREMENT,
  `nome_vendedor` VARCHAR(100) NOT NULL,
  `num_carros_vendidos_vendedor` INT(5) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_vendedor`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`venda_veiculo` (
    `id_venda_veiculo` INT NOT NULL AUTO_INCREMENT,
    `veiculo_id_veiculo` INT NOT NULL,
    `vendedor_id_vendedor` INT NOT NULL,
    `data_venda_veiculo` DATE NOT NULL,
    `valor_venda_veiculo` DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    `valor_comissao_venda_veiculo` DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id_venda_veiculo`),
    FOREIGN KEY (`veiculo_id_veiculo`)
        REFERENCES `mydb`.`veiculo` (`id_veiculo`),
    FOREIGN KEY (`vendedor_id_vendedor`)
        REFERENCES `mydb`.`vendedor` (`id_vendedor`)
)  ENGINE=INNODB;

INSERT INTO `mydb`.`veiculo`
(`id_veiculo`,
`modelo_veiculo`,
`marca_veiculo`,
`ano_fabricacao_veiculo`,
`ano_modelo_veiculo`,
`placa_veiculo`,
`chassi_veiculo`,
`valor_veiculo`)
VALUES
(1, 'Civic', 'Honda', 2017, 2018, 'HJA-9831', 99933182, 94374),
(2, 'Corolla', 'Toyota', 2016, 2016, 'HJC-9931', 99398103, 86346),
(3, 'Camaro', 'Chevrolet', 2014, 2015, 'HAV-8829', 99288131, 186711),
(4, 'Freemont', 'Fiat', 2011, 2012, 'FLJ-3128', 77312993, 52660),
(5, 'HRV', 'Honda', 2016, 2016, 'FAY-8221', 88331293, 84164);



INSERT INTO `mydb`.`vendedor`
(`id_vendedor`,
`nome_vendedor`,
`num_carros_vendidos_vendedor`)
VALUES
(1, 'Carlos', 1),
(2, 'Joaquim', 1),
(3, 'Júlia', 0),
(4, 'Letícia', 0),
(5, 'Roberto', 0);

delimiter $$

CREATE PROCEDURE vender_veiculo (IN id_do_veiculo INT, IN id_do_vendedor INT, 
OUT valor_comissao_venda decimal)

BEGIN

SET @valor=(select valor_veiculo from veiculo where id_do_veiculo=id_veiculo);
set @data_venda=curdate();
set @comissao=@valor*2/100;
set @valor_venda=@valor+@comissao;
set @valor_comissao_venda=@valor_venda;
insert into venda_veiculo (veiculo_id_veiculo, vendedor_id_vendedor, data_venda_veiculo,
valor_venda_veiculo, valor_comissao_venda_veiculo)
values(id_do_veiculo, id_do_vendedor, @data_venda, @valor_venda, @comissao);

END $$
delimiter ;

SET @com=0;

call vender_veiculo(1, 1, @com);
call vender_veiculo(2, 2, @com);
call vender_veiculo(3, 3, @com);
call vender_veiculo(4, 4, @com);

create view vendas as 
select modelo_veiculo, nome_vendedor, data_venda_veiculo, valor_comissao_venda_veiculo
from venda_veiculo, vendedor, veiculo
where veiculo_id_veiculo=id_veiculo and vendedor_id_vendedor=id_vendedor;

create view vendas_set as select
modelo_veiculo, valor_venda_veiculo
from veiculo, venda_veiculo 
where venda_veiculo.veiculo_id_veiculo=veiculo.id_veiculo and 
month(data_venda_veiculo)='9';

create view vendedor_master as select 
nome_vendedor from vendedor, venda_veiculo
where venda_veiculo.vendedor_id_vendedor=vendedor.id_vendedor
order by sum(valor_venda_veiculo);

delimiter $$
create function valor_vendedor (id_vendedor int) 
returns decimal(10,2)
begin
set @valorV='0';
select sum(valor_venda_veiculo) into @valorV from venda_veiculo 
where vendedor_id_vendedor = id_vendedor;
return @valorV;
end $$
delimiter ;


delimiter $$
create trigger increment_vendas after insert on venda_veiculo
for each row
begin 
update vendedor set
num_carros_vendidos_vendedor=num_carros_vendidos_vendedor+1
where id_vendedor = NEW.vendedor_id_vendedor;
end $$
delimiter ;





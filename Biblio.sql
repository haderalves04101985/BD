create database biblio_daniel;

use biblio_daniel;

#criando estruturas de dados

create table livro(
id_livro int primary key auto_increment,
titulo_livro varchar(100) not null);

create table usuario(
id_usuario int primary key auto_increment,
nome_usuario varchar(100) not null,
email_usuario varchar(250),
data_nasc_usuario date,
quant_emprest_usuario int not null default 0);

create table emprestimo(
id_emprestimo int primary key auto_increment,
usuario_id_usuario int not null,
livro_id_livro int not null,
data_emprestimo date not null,
data_devolucao date not null,
data_entrega date,
foreign key(usuario_id_usuario) references usuario(id_usuario),
foreign key(livro_id_livro) references livro(id_livro));

#inserindo dados

INSERT INTO livro (titulo_livro) VALUES
	("Bagagem"), 
	("O Cortiço"), 
	("Lira dos Vinte Anos"),
	("Quarup"),
	("O Tronco"),
	("A escrava Isaura"),
	("O Pagador de Promessas"),
	("O que é isso, Companheiro?"),
	("Vidas Secas"),
	("Grande Sertão Veredas");

    
INSERT INTO usuario (nome_usuario, email_usuario, 
data_nasc_usuario) VALUES
("João Silva", "joao@email.com", "1992-08-09"),
("Maria Mota", "maria@provedor.net", "1984-05-17"),
("Eduardo Cançado", "edu@email.com", "1996-02-23"),
("Silvia Alencar", "silvia@provedor.net", "1973-09-20"),
("Gabriela Medeiros", "gabi@email.com", "1993-01-10"),
("Karina Silva", "karin@email.com", "1995-03-25");


INSERT INTO emprestimo (usuario_id_usuario, livro_id_livro, data_emprestimo, data_devolucao, data_entrega) VALUES
	(1, 4, "2014-07-15", "2014-08-15", "2014-08-10"),
	(3, 2, "2014-08-22", "2014-09-22", "2014-09-21"),
	(2, 6, "2014-08-22", "2014-09-22", null),
	(2, 8, "2014-09-21", "2014-10-21", null),
	(1, 10, "2014-09-23", "2014-10-23", "2014-09-29"),
	(4, 2, "2014-09-23", "2014-10-23", null),
	(4, 7, "2014-09-23", "2014-10-23", null),
	(5, 3, "2014-09-24", "2014-10-24", null),
	(5, 9, "2014-09-24", "2014-10-24", null),
	(5, 1, "2014-09-24", "2014-10-24", null),
	(6, 3, "2014-09-01", "2014-10-01", "2014-09-30");
    
CREATE VIEW contatos_usuarios AS
SELECT nome_usuario, email_usuario
FROM usuario;

SELECT * FROM contatos_usuarios;

CREATE VIEW aniversarios_usuarios AS
SELECT nome_usuario, data_nasc_usuario
FROM usuario;

CREATE VIEW emprestimos_realizados AS
SELECT usuario.nome_usuario usuario, livro.titulo_livro
livro, emprestimo.data_emprestimo emprestimo,
emprestimo.data_devolucao devolucao,
emprestimo.data_entrega entrega
FROM usuario, livro, emprestimo
WHERE emprestimo.usuario_id_usuario = usuario.id_usuario
AND emprestimo.livro_id_livro = livro.id_livro;

CREATE VIEW emprestimos_atrasados AS
SELECT * FROM emprestimos_realizados
WHERE devolucao < curdate()
AND entrega is null;

CREATE VIEW quantidade_emprestimos_usuario
AS SELECT usuario, count(*) num_livros
FROM emprestimos_realizados
GROUP BY usuario;

UPDATE emprestimos_realizados
SET entrega = "2014-09-29"
WHERE usuario = "Karina Silva";

UPDATE contatos_usuarios
SET email_usuario = "silva@prov.net"
WHERE nome_usuario = "Karina Silva";


delimiter $$
CREATE PROCEDURE emprestar(IN usuario INT, IN livro INT)
BEGIN
SET @dt_emprestimo = curdate();
SET @dt_devolucao = adddate(@dt_emprestimo, 30);
INSERT INTO emprestimo (usuario_id_usuario,
livro_id_livro, data_emprestimo, data_devolucao)
VALUE (usuario, livro, @dt_emprestimo, @dt_devolucao);
END $$
delimiter ;

CALL emprestar(3,8);

delimiter $$
CREATE PROCEDURE emprestar_retorno(IN usuario INT, IN livro
INT, OUT devolucao DATE)
BEGIN
SET @dt_emprestimo = curdate();
SET @dt_devolucao = adddate(@dt_emprestimo, 30);
SELECT @dt_devolucao INTO devolucao;
INSERT INTO emprestimo (usuario_id_usuario, livro_id_livro,
data_emprestimo, data_devolucao)
VALUE (usuario, livro, @dt_emprestimo, @dt_devolucao);
END $$
delimiter ;

SET @devoluco='';
CALL emprestar_retorno(5, 1, @devolucao);
select @devolucao;

delimiter $$
CREATE PROCEDURE devolver(IN emprestimo INT)
BEGIN
SET @dt_entrega = curdate();
UPDATE emprestimo SET data_entrega = @dt_entrega
WHERE id_emprestimo = emprestimo;
END $$
delimiter ;

CALL devolver(13);


DELIMITER $$
CREATE FUNCTION quantidade_emprestimo (livro int)
RETURNS INTEGER
BEGIN
SET @num = 0;
SELECT count(*) INTO @num FROM emprestimo
WHERE livro_id_livro = livro;
RETURN @num;
RETURN 0;
END
$$
DELIMITER ;

SELECT quantidade_emprestimo(2);


delimiter $$
CREATE TRIGGER inc_quant_emprestimo AFTER
INSERT ON emprestimo
FOR EACH ROW
BEGIN
UPDATE usuario SET
quant_emprest_usuario = quant_emprest_usuario + 1
WHERE id_usuario = NEW.usuario_id_usuario;
END $$
delimiter ;


CALL emprestar(1,1);
CALL emprestar(1,2);
CALL emprestar(1,3);

CALL emprestar(2,1);
CALL emprestar(2,2);
CALL emprestar(2,3);

CALL emprestar(3,3);

CALL emprestar(2,10);
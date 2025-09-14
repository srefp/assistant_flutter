import { executeSql, getSqlStr, now } from "./Base";

export async function insert{{TableName}}({
{{# columns }}  {{columnName}}{{# columnDefault }} = {{columnDefault}}{{/ columnDefault }}{{# columnNull }} = null{{/ columnNull }}{{# notLast }},{{/notLast}}
  {{/ columns }}
}) {
    if (id) {
        const count = executeSql(`
            select count(*) from {{table_name}} where id = ${id};
        `);
        if (count === 1) {
            executeSql(`
                update {{table_name}} set{{# columns }}{{# notPk }}
                {{column_name}} = ${ {{sqlStrRes}} }{{# notLast }},{{/ notLast }}{{/ notPk }}{{/ columns }}
                where id = ${id};
            `);
            return id;
        }
    }
    return executeSql(`
        insert into {{table_name}}
        ({{# columns }}{{column_name}}{{# notLast }}, {{/ notLast }}{{/ columns }})
        values
        ({{# columns }}${ {{sqlStrRes}} }{{# notLast }}, {{/ notLast }}{{/ columns }})
        returning id;
    `);
}

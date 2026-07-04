/**
 * Spring根配置类，负责Service层组件扫描、MyBatis Mapper扫描、数据源、SqlSessionFactory及事务管理器的Bean定义。
 */
package org.example.zixuan.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;

@org.springframework.context.annotation.Configuration
@ComponentScan(basePackages = "org.example.zixuan.service")
@MapperScan("org.example.zixuan.mapper")
@EnableTransactionManagement
public class RootConfig {

    @Bean
    public DataSource dataSource() {
        String dbUrl = getEnvOrProperty("DB_URL",
                "jdbc:mysql://localhost:3306/3224003048_hst_campus_assist"
                        + "?useSSL=false&serverTimezone=UTC&characterEncoding=utf8");
        String dbUser = getEnvOrProperty("DB_USER", "root");
        String dbPass = getEnvOrProperty("DB_PASS", "123456");

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(dbUrl);
        config.setUsername(dbUser);
        config.setPassword(dbPass);
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        return new HikariDataSource(config);
    }

    private String getEnvOrProperty(String key, String defaultValue) {
        String env = System.getenv(key);
        if (env != null && !env.isBlank()) return env;
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) return prop;
        return defaultValue;
    }

    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
        factoryBean.setDataSource(dataSource);
        factoryBean.setTypeAliasesPackage("org.example.zixuan.model");
        factoryBean.setMapperLocations(
                new PathMatchingResourcePatternResolver().getResources("classpath:mapper/*.xml"));

        Configuration myBatisConfig = new Configuration();
        myBatisConfig.setMapUnderscoreToCamelCase(true);
        factoryBean.setConfiguration(myBatisConfig);
        return factoryBean.getObject();
    }

    @Bean
    public DataSourceTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}

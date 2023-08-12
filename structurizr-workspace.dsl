workspace {

    model {
        
        emailSystem = softwareSystem "Servidor de email" {
            description "Gmail API"
            tags "External"
        }

        bankingAggregator = softwareSystem "Agregador bancario" {
            description "Plaid"
            tags "External"
        }
    
        enterprise "Contexto del proyecto" {

            user = person "Usuario de Balancer" "Usuario del sistema Balancer, con gastos personales y una o varias cuentas bancarias o de correo electrónico."
            
            softwareSystem = softwareSystem "Balancer" {

                core = container "Servicio Core" \
                    "Coordina el resto de microservicios y provee la funcionalidad de Balancer a través de una API JSON/HTTPS." "Kotlin/Spring"

                database = container "Base de datos" {
                    description "Almacena credenciales de acceso e información sobre gastos, planificación y análisis."
                    tags "Database"
                    
                    core -> this \
                        "Consulta y escribe datos" "TCP/SQL"
                }
                
                group "Fuentes de datos" {
                    bankingConnector = container "Conector bancario" {
                        description "Gestiona la entrada de datos a través del agregador bancario."
                        technology "Kotlin/Spring"
                        
                        bankingAggregator -> this \
                            "Notifica y proporciona datos bancarios" "JSON/HTTPS"
                        
                        this -> core \
                            "Notifica y proporciona datos bancarios" "AMQP/TCP"
                    }

                    emailConnector = container "Conector de email" {
                        description "Gestiona la entrada de datos a través de correo electrónico."
                        technology "Kotlin/Spring"

                        emailSystem -> this \
                            "Proporciona recepción y envío de mensajes de email" "JSON/HTTPS"

                        this -> core \
                            "Notifica y proporciona datos de facturas y recibos" "AMQP/TCP"
                    }
                }
    
                group "Interacción con el usuario (frontend)"
                    notifications = container "Servicio de notificaciones" {
                        description "Gestiona el envío de notificaciones al usuario."
                        technology "Kotlin/Spring"

                        core -> this \
                            "Envía notificaciones" "AMQP/TCP"

                        this -> user \
                            "Envía notificaciones" "[TBD]"
                    }

                    webApp = container "Aplicación web" {
                        description "Provee la funcionalidad de Balancer a los usuarios a través de un navegador web."
                        technology "React"
                        tags "Web app"

                        user -> this \
                            "Planifica gastos personales de forma dinámica y consulta resúmenes"

                        this -> core \
                            "Interactúa con" "JSON/HTTPS"
                    }
                    
                    mobileApp = container "Aplicación móvil" {
                        description "Provee la funcionalidad de Balancer a los usuarios a través de un dispositivo móvil."
                        technology "[TBD]"
                        tags "Mobile app"

                        user -> this \
                            "Planifica gastos personales de forma dinámica y consulta resúmenes"

                        this -> core \
                            "Interactúa con" "JSON/HTTPS"
                    }
                }
            }
        }
    }

    views {
        systemContext softwareSystem "system-context-diagram" {
            title "Diagrama de contexto de Balancer"
            description "Modelo C4: diagrama de contexto del sistema."
            include *
        }

        container softwareSystem "container-diagram" {
            title "Diagrama de contenedores de Balancer"
            description "Modelo C4: diagrama de contenedores del sistema."
            include *
        }

        theme default

        styles {
            element "External" {
                background #666666
                color #ffffff 
            }

            element "Database" {
                shape Cylinder
            }

            element "Web app" {
                shape WebBrowser
            }

            element "Mobile app" {
                shape MobileDeviceLandscape
            }
        }
    }
}

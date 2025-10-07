import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("default")

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationId = "com.petrasoftsolutions.mobile.dev"
            resValue(type = "string", name = "app_name", value = "(Dev) Petrasoft School Management Solutions")
        }
        create("qa") {
            dimension = "default"
            applicationId = "com.petrasoftsolutions.mobile.qa"
            resValue(type = "string", name = "app_name", value = "(QA) Petrasoft School Management Solutions")
        }
        create("staging") {
            dimension = "default"
            applicationId = "com.petrasoftsolutions.mobile.staging"
            resValue(type = "string", name = "app_name", value = "(Staging) Petrasoft School Management Solutions")
        }
        create("prod") {
            dimension = "default"
            applicationId = "com.petrasoftsolutions.mobile.prod"
            resValue(type = "string", name = "app_name", value = "Petrasoft School Management Solutions")
        }
    }
}
# Feature Modules (Clean Architecture + MVVM)

Every feature in the application (e.g. `auth`, `dispatch`, `trips`) must be completely isolated under this directory. Do not mix dependencies across features.

## Folder Layout:

```
features/<feature_name>/
├── data/
│   ├── datasources/        # Local or remote API client adapters (Dio calls)
│   ├── models/             # Serialization / JSON mapping rules (extends domain entities)
│   └── repositories/       # Concrete implementation of domain repository interfaces
│
├── domain/
│   ├── entities/           # Pure business models (free of external framework imports)
│   ├── repositories/       # Abstract repository interfaces definitions
│   └── usecases/           # Specific business workflow executors
│
└── presentation/
    ├── controllers/        # GetxController (ViewModels handling state & validation)
    ├── views/              # Views/Pages (StatelessWidget or GetView)
    └── widgets/            # Private widgets specific to this feature
```

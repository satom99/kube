# Kube

Automatic node discovery on [Kubernetes](https://kubernetes.io).

### Configuration

The following values are optional.

```elixir
config :kube,
  master: "kubernetes.default.svc",
  selector: "app=my-app"
```

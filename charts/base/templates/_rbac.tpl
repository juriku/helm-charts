{{- define "base.rbac" -}}
{{- $root := . -}}

{{- if .Values.ClusterRole -}}
{{- range .Values.ClusterRole }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    {{- if .aggregationRule }}
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    {{- end }}
    {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  name: {{ .name }}
{{- with .aggregationRule }}
aggregationRule:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- with .rules }}
rules:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.ClusterRoleBinding -}}
{{- range .Values.ClusterRoleBinding }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- with .labels }}
  labels:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  name: {{ .name }}
subjects:
{{- with .subjects }}
{{ toYaml . }}
{{- end }}
{{- range .UserLists }}
{{- $valueRange := pluck . $root.Values.RbacUserLists | first }}
{{- range $valueRange }}
- kind: User
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- range .GroupLists }}
{{- $valueRange := pluck . $root.Values.RbacGroupLists | first }}
{{- range $valueRange }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.ioRoleBinding
{{- end }}
{{- end }}
{{- range .serviceAccountGroups }}
{{- $valueRange := pluck . $root.Values.serviceAccountGroups | first }}
{{- range $valueRange }}
- kind: ServiceAccount
  name: {{ .name | trim | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- range .kubeGroups }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
roleRef:
  kind: ClusterRole
  name: {{ .ClusterRoleName }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}

{{- if .Values.Role -}}
{{- range .Values.Role }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- if .labels -}}
  labels:
  {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- if .rules -}}
{{- with .rules }}
rules:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.RoleBinding -}}
{{- $root := . -}}
{{- $defaultNamespaces := .Values.defaultNamespaces }}
{{- range .Values.RoleBinding }}
{{- $coreRange := . -}}
{{- $rangeNamespaces := coalesce .namespaces (list .namespace) (list) }}
{{- $rangeNamespaces := ternary $defaultNamespaces $rangeNamespaces (.defaultNamespaces | default false) }}
{{- range $rangeNamespaces }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- with $coreRange.labels }}
  labels:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  name: {{ $coreRange.name }}
  {{- if . }}
  namespace: {{ . | quote }}
  {{- end }}
subjects:
{{- with $coreRange.subjects }}
{{ toYaml . }}
{{- end }}
{{- range $coreRange.UserLists }}
{{- $valueRange := pluck . $root.Values.RbacUserLists | first }}
{{- range $valueRange }}
- kind: User
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- range $coreRange.GroupLists }}
{{- $valueRange := pluck . $root.Values.RbacGroupLists | first }}
{{- range $valueRange }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- range $coreRange.serviceAccountGroups }}
{{- $valueRange := pluck . $root.Values.serviceAccountGroups | first }}
{{- range $valueRange }}
- kind: ServiceAccount
  name: {{ .name | trim | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- range $coreRange.kubeGroups }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
roleRef:
{{- if $coreRange.ClusterRoleName }}
  kind: ClusterRole
  name: {{ $coreRange.ClusterRoleName }}
{{- else if $coreRange.RoleName }}
  kind: Role
  name: {{ $coreRange.RoleName }}
{{- end }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end }}


{{- if .Values.ServiceAccount -}}
{{- range .Values.ServiceAccount }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  {{- with .labels }}
  labels:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- end }}
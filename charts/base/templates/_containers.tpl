{{/*
Normalise a container collection to an ordered list. A map is sorted by key,
because Go templates iterate maps in sorted order; a list keeps the order
given, which is what init containers need.
*/}}
{{- define "base.containerList" -}}
{{- $out := list -}}
{{- if kindIs "slice" . -}}
{{- $out = . -}}
{{- else -}}
{{- range $name, $values := . -}}
{{- $out = append $out (merge (dict "name" $name) ($values | default dict)) -}}
{{- end -}}
{{- end -}}
{{- toYaml $out -}}
{{- end }}

{{/*
Render one container. Takes a dict of "container" and "root".
*/}}
{{- define "base.container" -}}
{{- $c := .container -}}
{{- $root := .root -}}
- name: {{ $c.name }}
  {{- include "base.image" (merge dict ($c.image | default dict) $root.Values.image) | nindent 2 }}
  {{- with $c.ports }}
  ports:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- with include "base.containerDefaultProperties" $c }}
  {{- . | trim | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Render the init containers, when any are configured.
*/}}
{{- define "base.initContainers" -}}
{{- with .Values.initContainers }}
initContainers:
{{- range include "base.containerList" . | fromYamlArray }}
{{- include "base.container" (dict "container" . "root" $) | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Render the main container followed by any extra containers.
*/}}
{{- define "base.containers" -}}
containers:
{{- $main := merge (dict "name" (include "base.name" .)) .Values }}
{{- include "base.container" (dict "container" $main "root" .) | nindent 2 }}
{{- range include "base.containerList" (.Values.extraContainers | default dict) | fromYamlArray }}
{{- include "base.container" (dict "container" . "root" $) | nindent 2 }}
{{- end }}
{{- end }}

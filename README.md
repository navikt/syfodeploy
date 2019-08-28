# Syfo deployment orb og tooling

## Syfodeploy
Syfodeploy er et shell script som kan brukes for å bygge og deploye brances fra egen maskin. Scriptet trigger en CircleCI workflow som kan bygge og deploye valgfri branch. Scriptet autentiserer seg mot CircleCI, dette krever at du henter en api-key fra CircleCI. Scriptet prompter deg om dette hvis api-key ikke allerede er satt opp ved tidligere kjøring av scriptet. Når scriptet har en key vil den gjøre et post kall til CircleCI som starter workflowen med parametre som er gitt til scriptet.

I prosjektet du skal deploye, kjør komandoen: `sh <patt-til-syfodeploy>/syfodeploy.sh <prosjekt> <branch>`

For å gjøre livet lettere kan du opprette et alias for dette `alias "sh $HOME/path/to/syfodeploy/syfodeploy.sh"`.

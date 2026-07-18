
Action: file_editor str_replace /app/backend/server.py --old-str "    if await db.flights.count_documents({}) == 0:
        seed_flights = [
            Flight(flight_number=\"B2 869\", game=\"PTFS\", origin=\"UMMS Минск\", destination=\"LTFM Стамбул\", aircraft=\"Boeing 737-800\", departure_time=\"2026-02-15T18:00:00Z\", pilot=\"Capt. Ivanov\"),
            Flight(flight_number=\"B2 771\", game=\"PTFS\", origin=\"UMMS Минск\", destination=\"UUEE Москва\", aircraft=\"Embraer 195\", departure_time=\"2026-02-15T20:30:00Z\", pilot=\"Capt. Petrov\"),
            Flight(flight_number=\"B2 943\", game=\"PTFS\", origin=\"UMMS Минск\", destination=\"EDDF Франкфурт\", aircraft=\"Boeing 737-300\", departure_time=\"2026-02-16T09:15:00Z\", pilot=\"Capt. Sokolov\"),
            Flight(flight_number=\"OP 001\", game=\"FPS\", origin=\"Air Base Alpha\", destination=\"Combat Zone Delta\", aircraft=\"Су-27\", departure_time=\"2026-02-15T21:00:00Z\", pilot=\"Ace Volkov\", status=\"Посадка\"),
            Flight(flight_number=\"OP 002\", game=\"FPS\", origin=\"Air Base Bravo\", destination=\"Combat Zone Echo\", aircraft=\"МиГ-29\", departure_time=\"2026-02-16T14:00:00Z\", pilot=\"Ace Kozlov\"),
        ]
        await db.flights.insert_many([f.model_dump() for f in seed_flights])

    " --new-str "    "
Observation: Edit was successful.
Теперь очищаю уже созданные демо-рейсы из базы:
Action: $ API_URL=$(grep REACT_APP_BACKEND_URL /app/frontend/.env | cut -d '=' -f2) && \
curl -s "$API_URL/api/flights" | python3 -c "
import sys, json, subprocess, os
flights = json.load(sys.stdin)
print(f'Found {len(flights)} flights, deleting...')
for f in flights:
    subprocess.run(['curl', '-s', '-X', 'DELETE', f'{os.environ[\"API_URL\"]}/api/flights/{f[\"id\"]}', '-H', 'X-Admin-Code: 02082016'], check=True)
print('Done')
" API_URL="$API_URL" && \
echo "---" && \
curl -s "$API_URL/api/flights"
Observation: Found 5 flights, deleting...
[stderr] Traceback (most recent call last):
  File "<string>", line 6, in <module>
  File "<frozen os>", line 679, in __getitem__
KeyError: 'API_URL'
Exit code: 1

Action: $ API_URL=$(grep REACT_APP_BACKEND_URL /app/frontend/.env | cut -d '=' -f2) && \
export API_URL && \
curl -s "$API_URL/api/flights" | python3 -c "
import sys, json, subprocess, os
API=os.environ['API_URL']
flights = json.load(sys.stdin)
print(f'Deleting {len(flights)} flights...')
for f in flights:
    subprocess.run(['curl', '-s', '-X', 'DELETE', f'{API}/api/flights/{f[\"id\"]}', '-H', 'X-Admin-Code: 02082016'], check=True)
print('Done')
" && \
echo "Remaining:" && curl -s "$API_URL/api/flights"
Observation: Deleting 5 flights...
{"ok":true}{"ok":true}{"ok":true}{"ok":true}{"ok":true}Done
Remaining:
[]
Exit code: 0

Action: file_editor str_replace /app/frontend/src/components/Footer.jsx --old-str "                    <ul className=\"space-y-2 text-slate-300\">
                        <li className=\"flex items-center gap-2\"><Send className=\"w-4 h-4 text-[#0054A6]\" /> Telegram</li>
                        <li className=\"flex items-center gap-2\"><Github className=\"w-4 h-4\" /> GitHub</li>
                    </ul>" --new-str "                    <ul className=\"space-y-2 text-slate-300\">
                        <li>
                            <a
                                href=\"https://t.me/BelaviaPTFS\"
                                target=\"_blank\"
                                rel=\"noopener noreferrer\"
                                data-testid=\"footer-telegram-link\"
                                className=\"flex items-center gap-2 hover:text-[#0054A6] transition-colors\"
                            >
                                <Send className=\"w-4 h-4 text-[#0054A6]\" /> Telegram · @BelaviaPTFS
                            </a>
                        </li>
                        <li className=\"flex items-center gap-2 text-slate-500\"><Github className=\"w-4 h-4\" /> GitHub</li>
                    </ul>"
Observation: Edit was successful.

// การเชื่อมต่อ Supabase (โปรเจกต์ SAU_Anukol)
// publishable key ใช้ในแอปได้ เพราะตาราง run_tb และ bucket run_bk เปิด RLS และตั้ง Policy ไว้แล้ว
const String supabaseUrl = 'https://sttocbrgcaskecbowopt.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_wuCo6GmVP14T80CpJEbcQg_7oan0Y2u';

// ชื่อตารางและ bucket ใน Supabase
const String runTable = 'run_tb';
const String runBucket = 'run_bk';

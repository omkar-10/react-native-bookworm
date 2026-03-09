import cron from "cron";

const job = new cron.CronJob("*/14 * * * *", async () => {
  try {
    const response = await fetch(`${process.env.API_URL}/api/health`);
    console.log(
      `Keep-alive ping status: ${response.status} at ${new Date().toISOString()}`,
    );
  } catch (error) {
    console.error("Keep-alive ping failed:", error.message);
  }
});

export default job;
